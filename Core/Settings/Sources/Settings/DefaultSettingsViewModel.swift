//
//  DefaultSettingsViewModel.swift
//  Settings
//
//  Created by Fernando Barbat on 8/8/24.
//

import Observation

@MainActor
final class DefaultSettingsViewModel: SettingsViewModel {
    public let general: DefaultGeneralSettingsViewModel
    public let ollama: DefaultOllamaSettingsViewModel
    public let openAI: DefaultOpenAISettingsViewModel
    public let anthropic: DefaultAnthropicSettingsViewModel

    public init(
        general: DefaultGeneralSettingsViewModel,
        ollama: DefaultOllamaSettingsViewModel,
        openAI: DefaultOpenAISettingsViewModel,
        anthropic: DefaultAnthropicSettingsViewModel
    ) {
        self.general = general
        self.ollama = ollama
        self.openAI = openAI
        self.anthropic = anthropic
    }
}

@MainActor
@Observable
final class DefaultGeneralSettingsViewModel: GeneralSettingsViewModel {
    public var activeModel: GeneralSettingsViewModelActiveModel {
        get {
            access(keyPath: \.activeModel)
            return settingsApplicationModel.get(\.general.activeModel).asViewModel
        }
        
        set {
            withMutation(keyPath: \.activeModel) {
                settingsApplicationModel.set(\.general.activeModel, value: GeneralSettings.ActiveModel(newValue))
            }
        }
    }
    
    private let settingsApplicationModel: SettingsApplicationModel
    
    init(settingsApplicationModel: SettingsApplicationModel) {
        self.settingsApplicationModel = settingsApplicationModel
    }
}

extension GeneralSettings.ActiveModel {
    init(_ viewModel: GeneralSettingsViewModelActiveModel) {
        switch viewModel {
        case .ollama:
            self = .ollama
        case .openAI:
            self = .openAI
        case .anthropic:
            self = .anthropic
        }
    }
    
    var asViewModel: GeneralSettingsViewModelActiveModel {
        switch self {
        case .ollama:
            return .ollama
        case .openAI:
            return .openAI
        case .anthropic:
            return .anthropic
        }
    }
}

@MainActor
@Observable
final class DefaultOllamaSettingsViewModel: OllamaSettingsViewModel {
    public var url: String {
        get {
            access(keyPath: \.url)
            return settingsApplicationModel.get(\.ollama.url)
        }
        
        set {
            withMutation(keyPath: \.url) {
                settingsApplicationModel.set(\.ollama.url, value: newValue)
            }
        }
    }
    
    public var model: String {
        get {
            access(keyPath: \.model)
            return settingsApplicationModel.get(\.ollama.model)
        }
        
        set {
            withMutation(keyPath: \.model) {
                settingsApplicationModel.set(\.ollama.model, value: newValue)
            }
        }
    }
    
    private let settingsApplicationModel: SettingsApplicationModel
    
    init(settingsApplicationModel: SettingsApplicationModel) {
        self.settingsApplicationModel = settingsApplicationModel
    }
}

@MainActor
@Observable
final class DefaultOpenAISettingsViewModel: OpenAISettingsViewModel {
    var key: String {
        get {
            access(keyPath: \.key)
            return settingsApplicationModel.get(\.openAI.key)
        }
        
        set {
            withMutation(keyPath: \.key) {
                settingsApplicationModel.set(\.openAI.key, value: newValue)
            }
        }
    }
    
    var model: String {
        get {
            access(keyPath: \.model)
            return settingsApplicationModel.get(\.openAI.model)
        }
        
        set {
            withMutation(keyPath: \.model) {
                settingsApplicationModel.set(\.openAI.model, value: newValue)
            }
        }
    }
    
    private let settingsApplicationModel: SettingsApplicationModel
    
    init(settingsApplicationModel: SettingsApplicationModel) {
        self.settingsApplicationModel = settingsApplicationModel
    }
}

@MainActor
@Observable
final class DefaultAnthropicSettingsViewModel: AnthropicSettingsViewModel {
    var key: String {
        get {
            access(keyPath: \.key)
            return settingsApplicationModel.get(\.anthropic.key)
        }
        
        set {
            withMutation(keyPath: \.key) {
                settingsApplicationModel.set(\.anthropic.key, value: newValue)
            }
        }
    }
    
    var model: String {
        get {
            access(keyPath: \.model)
            return settingsApplicationModel.get(\.anthropic.model)
        }
        
        set {
            withMutation(keyPath: \.model) {
                settingsApplicationModel.set(\.anthropic.model, value: newValue)
            }
        }
    }
    
    private let settingsApplicationModel: SettingsApplicationModel
    
    init(settingsApplicationModel: SettingsApplicationModel) {
        self.settingsApplicationModel = settingsApplicationModel
    }
}

