//
//  FakeSettingsViewModel.swift
//  Settings
//
//  Created by Fernando Barbat on 8/8/24.
//

import Foundation

public final class FakeSettingsViewModel: SettingsViewModel {
    public let general: FakeGeneralSettingsViewModel
    public let ollama: FakeOllamaSettingsViewModel
    public let openAI: FakeOpenAISettingsViewModel
    public let anthropic: FakeAnthropicSettingsViewModel
    
    public init(
        general: FakeGeneralSettingsViewModel,
        ollama: FakeOllamaSettingsViewModel,
        openAI: FakeOpenAISettingsViewModel,
        anthropic: FakeAnthropicSettingsViewModel
    ) {
        self.general = general
        self.ollama = ollama
        self.openAI = openAI
        self.anthropic = anthropic
    }
}

public final class FakeGeneralSettingsViewModel: GeneralSettingsViewModel {
    public var activeModel: GeneralSettingsViewModelActiveModel
    
    public init(activeModel: GeneralSettingsViewModelActiveModel) {
        self.activeModel = activeModel
    }
}

public final class FakeOllamaSettingsViewModel: OllamaSettingsViewModel {
    public var url: String
    public var model: String
    
    public init(url: String, model: String) {
        self.url = url
        self.model = model
    }
}

public final class FakeOpenAISettingsViewModel: OpenAISettingsViewModel {
    public var key: String
    public var model: String
    
    public init(key: String, model: String) {
        self.key = key
        self.model = model
    }
}

public final class FakeAnthropicSettingsViewModel: AnthropicSettingsViewModel {
    public var key: String
    public var model: String
    
    public init(key: String, model: String) {
        self.key = key
        self.model = model
    }
}
