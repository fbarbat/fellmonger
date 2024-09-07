//
//  ChatMasterDetailViewModelFactory.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 18/5/24.
//

import Foundation

import Settings

@MainActor
public final class ChatModule {
    public let chatViewModel: ChatViewModel

    public init(settingsModule: SettingsModule) {
        chatViewModel = ChatViewModel(
            id: UUID().uuidString,
            entries: [],
            chatInputViewModel: ChatInputViewModel(),
            modelService: ConfigurableModelService(
                settingsApplicationModel: settingsModule.settingsApplicationModel,
                modelServiceFactory: { @Sendable [settingsApplicationModel = settingsModule.settingsApplicationModel] activeModel in
                    switch activeModel {
                    case .ollama:
                        return await OllamaService(settingsApplicationModel: settingsApplicationModel)
                    case .openAI:
                        return await OpenAIService(settingsApplicationModel: settingsApplicationModel)
                    case .anthropic:
                        return await AnthropicService(settingsApplicationModel: settingsApplicationModel)
                    }
                }
            )
        )
    }
}
