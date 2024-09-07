//
//  SettingsModule.swift
//  Settings
//
//  Created by Fernando Barbat on 8/8/24.
//

/// Module for the settings package.
/// Modules are the living instances of what is exported from the package.
@MainActor
public final class SettingsModule {
    public let settingsApplicationModel: SettingsApplicationModel

    public private(set) lazy var settingsViewModel: some SettingsViewModel = {
        DefaultSettingsViewModel(
            general: DefaultGeneralSettingsViewModel(settingsApplicationModel: settingsApplicationModel),
            ollama: DefaultOllamaSettingsViewModel(settingsApplicationModel: settingsApplicationModel),
            openAI: DefaultOpenAISettingsViewModel(settingsApplicationModel: settingsApplicationModel),
            anthropic: DefaultAnthropicSettingsViewModel(settingsApplicationModel: settingsApplicationModel)
        )
    }()
    
    public init(configurationPersistenceService: ConfigurationPersistenceService) {
        settingsApplicationModel = SettingsApplicationModel(configurationPersistenceService: configurationPersistenceService)
    }
}
