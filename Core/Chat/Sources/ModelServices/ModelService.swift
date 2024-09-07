//
//  ModelService.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 15/5/24.
//

import Foundation

public protocol ModelService: Sendable {
    func chat(messages: [ChatMessage]) async -> AsyncThrowingStream<ModelAction, Error>
}

public enum ChatMessage: Sendable {
    case user(UserChatMessage)
    case bot(BotChatMessage)
    case system(SystemChatMessage)
}

public struct UserChatMessage: Sendable {
    let content: String
}

public struct BotChatMessage: Sendable {
    let content: String
}

public struct SystemChatMessage: Sendable {
    let content: String
}

public enum ModelAction: Sendable {
    case appendChunk(String)
}
