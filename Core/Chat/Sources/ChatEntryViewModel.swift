//
//  ChatEntryViewModel.swift
//
//
//  Created by Fernando Barbat on 20/7/24.
//

import Observation
import SwiftExtensions

@MainActor
public final class ChatEntryViewModel {
    public let content: ChatEntryViewModelContent

    public init(content: ChatEntryViewModelContent) {
        self.content = content
    }

    public var id: String {
        switch content {
        case .system(let systemChatEntryViewModel):
            return systemChatEntryViewModel.id
        case .user(let userChatEntryViewModel):
            return userChatEntryViewModel.id
        case .chatbot(let chatbotChatEntryViewModel):
            return chatbotChatEntryViewModel.id
        }
    }
}

public enum ChatEntryViewModelContent {
    case system(SystemChatEntryViewModel)
    case user(UserChatEntryViewModel)
    case chatbot(ChatbotChatEntryViewModel)
}

public struct SystemChatEntryViewModel {
    let id: String
    let content: String

    public init(id: String, content: String) {
        self.id = id
        self.content = content
    }
}

public struct UserChatEntryViewModel {
    public let id: String
    public let content: String

    public init(id: String, content: String) {
        self.id = id
        self.content = content
    }
}

@Observable
@MainActor
public final class ChatbotChatEntryViewModel {
    public let id: String

    public enum State {
        case loading
        case done
        case error
    }

    public private(set) var state: State

    // TODO: This is just text for now but we could parse blocks as they arrive and actually append a list of blocks
    // to reduce rerendering big chunks of UI
    public private(set) var text: String

    private let task = AttachedTask<Void, Never>()

    public init(
        id: String,
        actions: AsyncThrowingStream<ModelAction, Error>
    ) {
        self.id = id
        state = .loading
        text = ""

        task.run { @MainActor [weak self] in
            do {
                for try await action in actions {
                    await self?.handle(action: action)
                }

                self?.state = .done
            } catch {
                self?.handle(error: error)
            }
        }
    }

    private func handle(action: ModelAction) async {
        switch action {
        case .appendChunk(let string):
            text += string
        }
    }

    private func handle(error: Error) {
        print(error)
        state = .error
        text = error.localizedDescription
    }
    
    func hasFinished() async {
        _ = await task.value
    }
}
