//
//  ChatViewModel.swift
//  
//
//  Created by Fernando Barbat on 20/7/24.
//
import Observation
import Foundation

@Observable
@MainActor
public final class ChatViewModel {
    public let chatInputViewModel: ChatInputViewModel
    
    public var anchoredToBottom: Bool = true

    public private(set) var entries: [ChatEntryViewModel]

    private let id: String
    private let modelService: ModelService

    public init(
        id: String,
        entries: [ChatEntryViewModel],
        chatInputViewModel: ChatInputViewModel,
        modelService: ModelService
    ) {
        self.id = id
        self.entries = entries
        self.modelService = modelService
        self.chatInputViewModel = chatInputViewModel

        chatInputViewModel.onSubmitted = { [weak self] prompt in
            await self?.send(prompt: prompt)
        }
    }

    public func reset() {
        entries = []
        chatInputViewModel.reset()
    }

    private func send(prompt: String) async {
        let userChatEntry = ChatEntryViewModel(
            content: .user(.init(
                id: UUID().uuidString,
                content: prompt
            ))
        )

        entries.append(userChatEntry)

        let messages = entries.map(\.asMessage)

        let chatbotChatEntryViewModel = ChatbotChatEntryViewModel(
            id: UUID().uuidString,
            actions: await modelService.chat(messages: messages)
        )

        entries.append(ChatEntryViewModel(content: .chatbot(chatbotChatEntryViewModel)))

        anchoredToBottom = true
        
        await chatbotChatEntryViewModel.hasFinished()
    }
}

private extension ChatEntryViewModel {
    var asMessage: ChatMessage {
        switch content {
        case .chatbot(let chatbot):
            return .bot(.init(
                content: chatbot.text
            ))

        case .system(let system):
            return .system(.init(content: system.content))

        case .user(let user):
            return .user(.init(content: user.content))
        }
    }
}
