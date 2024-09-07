//
//  ChatInputViewModel.swift
//
//
//  Created by Fernando Barbat on 20/7/24.
//

import Observation

public enum ChatInputViewModelState {
    case sending
    case ready
}

@Observable
@MainActor
public final class ChatInputViewModel {
    public var prompt: String

    public var onSubmitted: ((String) async -> Void)?

    public private(set) var state: ChatInputViewModelState = .ready

    private var sendingTask: Task<Void, Never>?

    public init(prompt: String = "") {
        self.prompt = prompt
    }

    public func send() {
        guard !prompt.isEmpty, sendingTask == nil else {
            return
        }

        let prompt = prompt
        self.prompt = ""

        sendingTask = Task {
            state = .sending
            await onSubmitted?(prompt)
            state = .ready
            sendingTask = nil
        }
    }

    public func reset() {
        cancel()
        prompt = ""
    }

    private func cancel() {
        guard let sendingTask else {
            return
        }

        sendingTask.cancel()
    }

    public func mainAction() {
        switch state {
        case .sending:
            cancel()
        case .ready:
            send()
        }
    }
}
