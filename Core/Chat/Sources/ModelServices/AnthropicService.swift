//
//  AnthropicService.swift
//
//
//  Created by Fernando Barbat on 16/7/24.
//

import Foundation

import SwiftExtensions
import Settings

@preconcurrency import SwiftAnthropic

/// The SwiftAnthropic library is preconcurrency so the easiest and safest way to integrate with it is to be in the main actor.
@MainActor
final class AnthropicService: ModelService {
    private var service: any SwiftAnthropic.AnthropicService
    
    private let task = AttachedTask<Void, Never>()
    
    private let settingsApplicationModel: SettingsApplicationModel

    init(settingsApplicationModel: SettingsApplicationModel) async {
        self.settingsApplicationModel = settingsApplicationModel
        
        let key = settingsApplicationModel.get(\.anthropic.key)
        service = AnthropicServiceFactory.service(apiKey: key)
        
        task.run { @MainActor [weak self] in
            for await key in settingsApplicationModel.onChange(of: \.anthropic.key) {
                self?.setKey(key)
            }
        }
    }
    
    private func setKey(_ key: String) {
        service = AnthropicServiceFactory.service(apiKey: key)
    }

    nonisolated func chat(messages: [ChatMessage]) -> AsyncThrowingStream<ModelAction, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                await self.doChat(messages: messages, continuation: continuation)
            }
        }
    }

    private func doChat(messages: [ChatMessage], continuation: AsyncThrowingStream<ModelAction,Error>.Continuation) async {
        let parameters = MessageParameter(
            model: .other(settingsApplicationModel.get(\.anthropic.model)),
            messages: messages.map(\.asAnthropicMessage),
            maxTokens: 1024
        )

        // This is to tell the compiler it is safe to call the streamMessage method (not explicit main actor) from
        // the current main actor context
        nonisolated(unsafe) let service = self.service

        do {
            let stream = try await service.streamMessage(parameters)
            for try await result in stream {
                if let text = result.delta?.text {
                    continuation.yield(.appendChunk(text))
                }
            }
            continuation.finish()
        } catch {
            continuation.finish(throwing: error)
        }
    }
}

extension ChatMessage {
    fileprivate var asAnthropicMessage: MessageParameter.Message {
        switch self {
        case .user(let userChatMessage):
            return .init(role: .user, content: .text(userChatMessage.content))
        case .bot(let botChatMessage):
            return .init(role: .assistant, content: .text(botChatMessage.content))
        case .system(let systemChatMessage):
            // TODO: Fix me
            return .init(role: .assistant, content: .text(systemChatMessage.content))
        }
    }
}
