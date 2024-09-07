//
//  SettingsPersistenceService.swift
//  Settings
//
//  Created by Fernando Barbat on 7/8/24.
//

/// Platform specific implementation for settings persistence
public protocol ConfigurationPersistenceService {
    func get(key: String) -> String?
    func set(key: String, value: String)
}

/// Fake implementation of ConfigurationPersistenceService useful for tests
public final class InMemoryConfigurationPersistenceService: ConfigurationPersistenceService {
    private var dictionary: [String: String] = [:]

    public func get(key: String) -> String? {
        dictionary[key]
    }

    public func set(key: String, value: String) {
        dictionary[key] = value
    }
}

