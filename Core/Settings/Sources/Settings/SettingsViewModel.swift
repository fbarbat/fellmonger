//
//  SettingsViewModel.swift
//  Settings
//
//  Created by Fernando Barbat on 8/8/24.
//

import Observation

@MainActor
public protocol SettingsViewModel {
    associatedtype General: GeneralSettingsViewModel
    associatedtype Ollama: OllamaSettingsViewModel
    associatedtype OpenAI: OpenAISettingsViewModel
    associatedtype Anthropic: AnthropicSettingsViewModel

    var general: General { get }
    var ollama: Ollama { get }
    var openAI: OpenAI { get }
    var anthropic: Anthropic { get }
}

@MainActor
public protocol GeneralSettingsViewModel: AnyObject, Observable {
    var activeModel: GeneralSettingsViewModelActiveModel { get set }
}

public enum GeneralSettingsViewModelActiveModel: String, CaseIterable, Identifiable {
    case ollama
    case openAI
    case anthropic

    public var id: Self { self }
    
    public var label: String {
        switch self {
        case .ollama:
            return "Ollama"
        case .openAI:
            return "OpenAI"
        case .anthropic:
            return "Anthropic"
        }
    }
}

@MainActor
public protocol OllamaSettingsViewModel: AnyObject, Observable {
    var url: String { get set }
    var model: String { get set }
}

@MainActor
public protocol OpenAISettingsViewModel: AnyObject, Observable {
    var key: String { get set }
    var model: String { get set }
}

@MainActor
public protocol AnthropicSettingsViewModel: AnyObject, Observable {
    var key: String { get set }
    var model: String { get set }
}
