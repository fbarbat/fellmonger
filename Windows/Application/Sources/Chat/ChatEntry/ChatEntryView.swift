import Chat

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

@MainActor
final class ChatEntryView {
    enum NestedView {
        case user(UserChatEntryView)
        case chatbot(ChatbotChatEntryView)
        case system(SystemChatEntryView)
    }

    private let nestedView: NestedView

    init(viewModel: ChatEntryViewModel) {
        switch viewModel.content {
        case .user(let userChatEntryViewModel):
            nestedView = .user(UserChatEntryView(viewModel: userChatEntryViewModel))
        case .chatbot(let chatbotChatEntryViewModel):
            nestedView = .chatbot(ChatbotChatEntryView(viewModel: chatbotChatEntryViewModel))
        case .system:
            nestedView = .system(SystemChatEntryView())
        }
    }

    var view: FrameworkElement {
        switch nestedView {
        case .user(let userChatEntryView):
            return userChatEntryView.view
        case .chatbot(let chatbotChatEntryView):
            return chatbotChatEntryView.view
        case .system(let systemChatEntryView):
            return systemChatEntryView.view
        }
    }
}
