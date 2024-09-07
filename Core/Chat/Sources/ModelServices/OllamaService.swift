//
//  Llama3Service.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 15/5/24.
//

import Foundation
@preconcurrency import OllamaKit
import Settings
import SwiftExtensions

/// Public just because it is useful to use this service from tests
public final actor OllamaService: ModelService {
    private enum State {
        case ready(OllamaKit)
        case invalidURL
    }
    
    private var state: State = .invalidURL
    
    private let settingsApplicationModel: SettingsApplicationModel
    
    private let task = AttachedTask<Void, Never>()
    
    public init(settingsApplicationModel: SettingsApplicationModel) async {
        self.settingsApplicationModel = settingsApplicationModel
        
        let url = await settingsApplicationModel.get(\.ollama.url)
        state = Self.makeState(url: url)
        
        task.run { [weak self] in
            for await url in await settingsApplicationModel.onChange(of: \.ollama.url) {
                await self?.setUrl(url)
            }
        }
    }
    
    public init() async {
        await self.init(settingsApplicationModel: await SettingsApplicationModel { _ in })
    }
    
    private func setUrl(_ url: String) async {
        state = Self.makeState(url: url)
    }
    
    private static func makeState(url: String) -> State {
        guard let baseURL = URL(string: url) else {
            return .invalidURL
        }
        
        return .ready(OllamaKit(baseURL: baseURL))
    }
    
    public nonisolated func chat(messages: [ChatMessage]) -> AsyncThrowingStream<ModelAction, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                await self.sendChat(messages: messages, continuation: continuation)
            }
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    private enum SendChatError: LocalizedError {
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The Ollama URL is not valid. Go to Settings to fix it."
            }
        }
    }
    
    private func sendChat(messages: [ChatMessage], continuation: AsyncThrowingStream<ModelAction, Error>.Continuation) async {
        switch state {
        case .invalidURL:
            continuation.finish(throwing: SendChatError.invalidURL)
            
        case .ready(let ollamaKit):
            let messages = messages.map { message in
                OKChatRequestData.Message(
                    role: message.asRole,
                    content: message.content
                )
            }
            
            let model = await settingsApplicationModel.get(\.ollama.model)
            
            do {
                // TODO: I think OllamaKit doesn't support cancellation
                for try await response in ollamaKit.chat(data: .init(
                    model: model,
                    messages: messages
                )) {
                    if response.done {
                        continuation.finish()
                        return
                    }
                    
                    if let message = response.message {
                        continuation.yield(.appendChunk(message.content))
                    }
                }
                
                continuation.finish()
            } catch {
                continuation.yield(with: .failure(error))
            }
        }
    }
}

private extension ChatMessage {
    var asRole: OKChatRequestData.Message.Role {
        switch self {
        case .user:
            return .user
        case .bot:
            return .assistant
        case .system:
            return .system
        }
    }
    
    var content: String {
        switch self {
        case .user(let userChatMessage):
            return userChatMessage.content
        case .bot(let botChatMessage):
            return botChatMessage.content
        case .system(let systemChatMessage):
            return systemChatMessage.content
        }
    }
}
