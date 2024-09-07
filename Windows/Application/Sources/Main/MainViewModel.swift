//
//  MainViewModel.swift
//  
//
//  Created by Fernando Barbat on 14/8/24.
//

import Observation

import Chat
import Settings

@Observable
@MainActor
final class MainViewModel {
    let chatViewModel: ChatViewModel
    let settingsViewModel: any SettingsViewModel

    public init(chatViewModel:ChatViewModel, settingsViewModel: any SettingsViewModel) {
        self.chatViewModel = chatViewModel
        self.settingsViewModel = settingsViewModel
    }

    public func reset() {
        chatViewModel.reset()
    }
}
