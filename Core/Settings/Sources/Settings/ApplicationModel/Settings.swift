//
//  Settings.swift
//  Settings
//
//  Created by Fernando Barbat on 7/8/24.
//

import Foundation

/// Model for default values for Settings.
/// This structure defines the paths of the configuration entries and their default values.
/// Their keypaths are automatically mapped to string full paths using #stringKeyPath.
public struct Settings: Sendable {
    public let general = GeneralSettings()
    public let ollama = OllamaSettings()
    public let openAI = OpenAISettings()
    public let anthropic = AnthropicSettings()
}

public struct GeneralSettings: Sendable {
    public enum ActiveModel: String, CaseIterable, Sendable {
        case ollama
        case openAI
        case anthropic
    }

    public let activeModel = SettingsEntry(key: "general.activeModel", defaultValue: ActiveModel.ollama)
}

public struct OllamaSettings: Sendable {
    public let url = SettingsEntry(key: "ollama.url", defaultValue: "http://localhost:11434")
    public let model = SettingsEntry(key: "ollama.model", defaultValue: "llama3.1")
}

public struct OpenAISettings: Sendable {
    public let key = SettingsEntry(key: "openAI.key", defaultValue: "")
    public let model = SettingsEntry(key: "openAI.model", defaultValue: "gpt-4o")
}

public struct AnthropicSettings: Sendable {
    public let key = SettingsEntry(key: "anthropic.key", defaultValue: "")
    public let model = SettingsEntry(key: "anthropic.model", defaultValue: "claude-3-5-sonnet-20240620")
}

public struct SettingsEntry<T: LosslessStringConvertible & Sendable>: Sendable {
    let key: String
    let defaultValue: T
}

extension GeneralSettings.ActiveModel: LosslessStringConvertible {
        public init?(_ description: String) {
            guard let activeModel = Self.allCases.first(where: { activeModel in activeModel.description == description}) else {
                return nil
            }
            
            self = activeModel
        }
        
    public var description: String {
        rawValue
    }
}
