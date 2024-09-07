//
//  AsyncThrowingStream+AppAdditions.swift
//
//
//  Created by Fernando Barbat on 5/6/24.
//

@preconcurrency import OpenCombine
import Foundation

/// Application model for Settings.
/// This class makes it easy to read, write, and listen for changes of settings.
/// As it is an application model, it lives in the main actor.
@MainActor
public final class SettingsApplicationModel {
    private static let settings = Settings()
    
    private let configurationPersistenceService: any ConfigurationPersistenceService
    private var passthroughSubjects: [PartialKeyPath<Settings>: PassthroughSubject<Any, Never>] = [:]

    public init(configurationPersistenceService: any ConfigurationPersistenceService) {
        self.configurationPersistenceService = configurationPersistenceService
    }
    
    public init(initializer: (@Sendable (SettingsApplicationModel) -> Void)? = nil) {
        self.configurationPersistenceService = InMemoryConfigurationPersistenceService()
        initializer?(self)
    }
    
    public func get<P: LosslessStringConvertible & Sendable>(_ keyPath: KeyPath<Settings, SettingsEntry<P>>) -> P {
        let entry = Self.settings[keyPath: keyPath]
        
        guard
            let stringValue = configurationPersistenceService.get(key: entry.settingsPath),
            let value = P(stringValue)
        else {
            return entry.defaultValue
        }
            
        return value
    }
    
    public func set<P: LosslessStringConvertible & Sendable>(_ keyPath: KeyPath<Settings, SettingsEntry<P>>, value: P) {
        let entry = Self.settings[keyPath: keyPath]
        let settingsPath = entry.settingsPath
        let stringValue = value.description
        let currentStringValue = configurationPersistenceService.get(key: settingsPath)
        
        if stringValue == currentStringValue {
            return
        }
            
        configurationPersistenceService.set(key: settingsPath, value: stringValue)
        passthroughSubjects[keyPath]?.send(value)
    }
    
    public func onChange<P: LosslessStringConvertible & Sendable>(of keyPath: KeyPath<Settings, SettingsEntry<P>>) -> AsyncStream<P> {
        return AsyncStream<P>(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let passthroughSubject = passthroughSubjects[keyPath] ?? {
                let passthroughSubject = PassthroughSubject<Any, Never>()
                passthroughSubjects[keyPath] = passthroughSubject
                return passthroughSubject
            }()
                
            let cancellable = passthroughSubject
                .compactMap { value in value as? P }
                .sink { value in
                    continuation.yield(value)
                }
                
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

private extension SettingsEntry {
    var settingsPath: String {
        "settings.\(key)"
    }
}
