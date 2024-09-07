//
//  MacOSSettingsModule.swift
//  MacOSSettings
//
//  Created by Fernando Barbat on 8/8/24.
//

import Settings

@MainActor
public final class MacOSSettingsModule {
    public let settingsApplicationModel: SettingsApplicationModel
    public let settingsViewModel: any SettingsViewModel
    
    public let settingsModule: SettingsModule
    
    public init() {
        settingsModule = SettingsModule(configurationPersistenceService: UserDefaultsConfigurationPersistenceService())
        
        settingsApplicationModel = settingsModule.settingsApplicationModel
        settingsViewModel = settingsModule.settingsViewModel
    }
}
