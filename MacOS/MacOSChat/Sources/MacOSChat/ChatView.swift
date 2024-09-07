//
//  LoadedActiveChatView.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 10/5/24.
//

import Chat
import MacOSSwiftExtensions

import SwiftUI

@MainActor
struct ChatView: View {
    @Bindable var model: ChatViewModel

    var body: some View {
        VStack {
            AnchoringScrollView(anchoredToBottom: $model.anchoredToBottom) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(model.entries, id: \.id) { entry in
                        ChatEntryView(model: entry)
                            .id(entry.id)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.default, value: model.entries.count)
                .textSelection(.enabled)
                .padding(.leading)
                .padding(.trailing)
                .padding(.top)
            }

            ChatInputView(model: model.chatInputViewModel)
                .padding()
        }
    }
}

struct ContentFrameKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct ContainerFrameKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

#Preview {
    AsyncPreviewView {
        ChatView(
            model: ChatViewModel(
                id: "",
                entries: [],
                chatInputViewModel: ChatInputViewModel(),
                modelService: await OllamaService()
            )
        )
    }
}

#Preview("Prefilled") {
    AsyncPreviewView {
        ChatView(
            model: ChatViewModel(
                id: "",
                entries: [
                    .init(
                        content: .user(.init(
                            id: UUID().uuidString,
                            content: "Can you look at my desktop please?"
                        ))
                    ),
                    .init(
                        content: .chatbot(.init(
                            id: UUID().uuidString,
                            actions: AsyncThrowingStream(elements: [
                                .appendChunk("I did and it looks good to me"),
                            ])
                        ))
                    ),
                ],
                chatInputViewModel: ChatInputViewModel(),
                modelService: await OllamaService()
            )
        )
    }
}

#Preview("Reset") {
    AsyncPreviewView {
        let modelService = await OllamaService()

        let chatViewModel = ChatViewModel(
            id: "",
            entries: [
                .init(
                    content: .user(.init(
                        id: UUID().uuidString,
                        content: "Can you look at my desktop please?"
                    ))
                ),
                .init(
                    content: .chatbot(.init(
                        id: UUID().uuidString,
                        actions: AsyncThrowingStream(elements: [
                            .appendChunk("I did and it looks good to me"),
                        ])
                    ))
                ),
            ],
            chatInputViewModel: ChatInputViewModel(prompt: "something"),
            modelService: modelService
        )

        return ChatView(model: chatViewModel)
            .task {
                try? await Task.sleep(for: .seconds(1))
                chatViewModel.reset()
            }
    }
}
