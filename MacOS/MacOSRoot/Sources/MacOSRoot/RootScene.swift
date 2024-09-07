import SwiftUI

import Chat
import MacOSChat
import Settings
import MacOSSettings

@MainActor
public struct RootScene: Scene {
    private let model: RootSceneModel

    public init(model: RootSceneModel) {
        self.model = model
    }

    public var body: some Scene {
        WindowGroup {
            MainView(model: model.mainViewModel)
        }

        Settings {
            SettingsView(model: model.settingsViewModel)
        }
        .defaultSize(width: 400, height: 400)
    }
}

@Observable
@MainActor
public final class RootSceneModel {
    let mainViewModel: MainViewModel
    let settingsViewModel: any SettingsViewModel

    private let settingsModule: MacOSSettingsModule
    private let chatModule: ChatModule

    public init() {
        settingsModule = MacOSSettingsModule()
        settingsViewModel = settingsModule.settingsViewModel

        let chatModule = ChatModule(settingsModule: settingsModule.settingsModule)
        self.chatModule = chatModule
        
        mainViewModel = MainViewModel(chatViewModel: chatModule.chatViewModel)
    }
}
