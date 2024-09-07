//
//  ContentView.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 10/5/24.
//

import SwiftUI

import Chat
import MacOSSwiftExtensions

public struct MainView: View {
    @Bindable private var model: MainViewModel

    public init(model: MainViewModel) {
        self.model = model
    }

    public var body: some View {
        ChatView(model: model.chatViewModel)
            .toolbar {
                Button(
                    action: {
                        model.reset()
                    },
                    label: {
                        Image(systemName: "trash")
                    }
                )

                SettingsLink()
            }
    }
}

#Preview {
    AsyncPreviewView {
        MainView(model: MainViewModel(
            chatViewModel: ChatViewModel(
                id: UUID().uuidString,
                entries: [],
                chatInputViewModel: ChatInputViewModel(),
                modelService: await OllamaService()
            )
        ))
    }
}
