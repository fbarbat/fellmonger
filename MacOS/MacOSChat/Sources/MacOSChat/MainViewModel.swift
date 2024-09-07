//
//  MainViewModel.swift
//  
//
//  Created by Fernando Barbat on 20/7/24.
//

import Observation

import Chat

@Observable
@MainActor
public class MainViewModel {
    public let chatViewModel: ChatViewModel

    public init(chatViewModel:ChatViewModel) {
        self.chatViewModel = chatViewModel
    }

    public func reset() {
        chatViewModel.reset()
    }
}
