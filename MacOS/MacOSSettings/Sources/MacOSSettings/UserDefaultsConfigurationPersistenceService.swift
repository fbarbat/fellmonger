//
//  UserDefaultsConfigurationPersistenceService.swift
//  MacOSSettings
//
//  Created by Fernando Barbat on 7/8/24.
//

import Settings
import Foundation

final class UserDefaultsConfigurationPersistenceService: ConfigurationPersistenceService {
    func get(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    
    func set(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
