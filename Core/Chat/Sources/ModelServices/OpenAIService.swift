//
//  OpenAIService.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 16/5/24.
//

import Foundation
import OpenAI
import Settings
import SwiftExtensions

final actor OpenAIService: ModelService {
    private var openAI: OpenAI
    
    private let task = AttachedTask<Void, Never>()
    
    private let settingsApplicationModel: SettingsApplicationModel
    
    init(settingsApplicationModel: SettingsApplicationModel) async {
        self.settingsApplicationModel = settingsApplicationModel
        
        let key = await settingsApplicationModel.get(\.openAI.key)
        openAI = OpenAI(apiToken: key)
        
        task.run { [weak self] in
            for await key in await settingsApplicationModel.onChange(of: \.openAI.key) {
                await self?.setKey(key)
            }
        }
    }

    private func setKey(_ key: String) {
        openAI = OpenAI(apiToken: key)
    }
    
    nonisolated func chat(messages: [ChatMessage]) -> AsyncThrowingStream<ModelAction, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                await chatsStream(messages: messages, continuation: continuation)
            }
        }
    }
    
    private func chatsStream(messages: [ChatMessage], continuation: AsyncThrowingStream<ModelAction, Error>.Continuation) async {
        let resultHandler = ResultHandler(continuation: continuation)
        
        // TODO: OpenAI library doesn't seem to support cancellation
        openAI.chatsStream(
            query: await makeChatQuery(messages: messages),
            onResult: { result in
                resultHandler.handle(result: result)
            },
            completion: { error in
                resultHandler.handleCompletion(error: error)
            }
        )
    }
    
    private func makeChatQuery(messages: [ChatMessage]) async -> ChatQuery {
        ChatQuery(
            messages: messages.map(\.asChatCompletionMessage),
            model: await settingsApplicationModel.get(\.openAI.model)
        )
    }
}

private class ResultHandler {
    private let continuation: AsyncThrowingStream<ModelAction, Error>.Continuation
    
    private var lastID: String?
    
    init(continuation: AsyncThrowingStream<ModelAction, Error>.Continuation) {
        self.continuation = continuation
    }
    
    func handle(result: Result<ChatStreamResult, Error>) {
        switch result {
        case .success(let chatStreamResult):
            handle(chatStreamResult: chatStreamResult)
        case .failure(let failure):
            handle(failure: failure)
        }
    }
    
    private func handle(chatStreamResult: ChatStreamResult) {
        guard let choice = chatStreamResult.choices.first else {
            return
        }
        
        if let chunk = choice.delta.content {
            continuation.yield(.appendChunk(chunk))
        }
    }
    
    private func handle(failure: Error) {
        continuation.finish(throwing: failure)
    }
    
    func handleCompletion(error: Error?) {
        if let error {
            continuation.finish(throwing: error)
        } else {
            continuation.finish()
        }
    }
}

enum ToolName: String {
    case getDesktopContext
    case setText
    case performAction
}

protocol StringArgumentsDecodable: Decodable {
    init?(arguments: String)
}

extension StringArgumentsDecodable {
    init?(arguments: String) {
        do {
            guard let data = arguments.data(using: .utf8) else {
                return nil
            }
            
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }
}

private struct SetTextParameters: StringArgumentsDecodable {
    let id: Int
    let text: String
}

private struct PerformActionsParameters: Decodable {
    let id: Int
    let action: String
    
    init?(arguments: String) {
        do {
            guard let data = arguments.data(using: .utf8) else {
                return nil
            }
            
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }
}

private extension ChatMessage {
    var asChatCompletionMessage: ChatQuery.ChatCompletionMessageParam {
        switch self {
        case .user(let message):
            return message.asChatCompletionMessage
        case .bot(let message):
            return message.asChatCompletionMessage
        case .system(let message):
            return message.asChatCompletionMessage
        }
    }
}

private extension UserChatMessage {
    var asChatCompletionMessage: ChatQuery.ChatCompletionMessageParam {
        return .user(.init(content: .string(content)))
    }
}

private extension BotChatMessage {
    var asChatCompletionMessage: ChatQuery.ChatCompletionMessageParam {
        return .assistant(.init(
            content: content
        ))
    }
}

private extension SystemChatMessage {
    var asChatCompletionMessage: ChatQuery.ChatCompletionMessageParam {
        return .system(.init(content: content))
    }
}

private extension ChatQuery.ChatCompletionMessageParam.ChatCompletionAssistantMessageParam.ChatCompletionMessageToolCallParam.FunctionCall {
    /// As the framework doesn't expose this init method, we implement it with this hack
    init(arguments: String, name: String) {
        let data = try! JSONEncoder().encode(FunctionCallPublicInitHack(arguments: arguments, name: name))
        
        self = try! JSONDecoder().decode(
            ChatQuery.ChatCompletionMessageParam.ChatCompletionAssistantMessageParam.ChatCompletionMessageToolCallParam.FunctionCall.self,
            from: data
        )
    }
}

private struct FunctionCallPublicInitHack: Encodable {
    let arguments: String
    let name: String
}
