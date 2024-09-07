//
//  ChatEntryView.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 15/5/24.
//

import SwiftUI

import Chat
import SwiftExtensions

import MarkdownUI

struct ChatEntryView: View {
    let model: ChatEntryViewModel

    var body: some View {
        switch model.content {
        case .chatbot(let model):
            ChatbotChatEntryView(model: model)
        case .user(let model):
            UserChatEntryView(model: model)
        case .system:
            EmptyView()
        }
    }
}

private struct UserChatEntryView: View {
    let model: UserChatEntryViewModel

    var body: some View {
        HStack(alignment: .top) {
            Spacer()

            MarkdownView(text: model.content)
                .padding()
                .background {
                    UnevenRoundedRectangle(cornerRadii: .init(
                        topLeading: 12,
                        bottomLeading: 12,
                        bottomTrailing: 12,
                        topTrailing: 0
                    ))
                    .fill()
                    .foregroundStyle(Color(nsColor: .controlColor))
                    .shadow(radius: 1, y: 0.5)
                }
                .opacity(0.7)
        }
    }
}

private struct ChatbotChatEntryView: View {
    let model: ChatbotChatEntryViewModel

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if model.state == .loading, model.text.isEmpty {
                    ProgressView()
                        .frame(width: 10, height: 10)
                        .scaleEffect(0.3)
                        .padding(3)

                } else {
                    MarkdownView(text: model.text)
                }
            }
            .padding()
            .background {
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: 12,
                    bottomTrailing: 12,
                    topTrailing: 12
                ))
                .fill()
                .foregroundStyle(Color(nsColor: .controlColor))
                .shadow(radius: 1, y: 0.5)
            }
            .padding(.bottom, 2)

            Spacer()
        }
    }
}

private struct MarkdownView: View {
    let text: String

    var body: some View {
        Markdown(text)
            .markdownBlockStyle(\.codeBlock) { configuration in
                configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .background(
                        RoundedRectangle(
                            cornerSize: CGSize(
                                width: 8,
                                height: 8
                            )
                        )
                        .stroke(lineWidth: 1)
                        .foregroundStyle(.gray)
                        .clipShape(
                            RoundedRectangle(
                                cornerSize: CGSize(
                                    width: 8,
                                    height: 8
                                )
                            )
                        )
                    )
                    .padding(.bottom)
            }
            .markdownCodeSyntaxHighlighter(
                SplashCodeSyntaxHighlighter(theme: .sunset(withFont: .init(size: 16)))
            )
    }
}

#Preview("User") {
    ChatEntryView(
        model: ChatEntryViewModel(
            content: .user(
                .init(
                    id: "1",
                    content: "Hello"
                )
            )
        )
    )
    .padding()
}

private let testCode = """
```swift
func someFunction() {
  let someVariable = 1
  print("Hello world!")
}
```
"""

#Preview("User Code") {
    ChatEntryView(
        model: ChatEntryViewModel(
            content: .user(
                .init(
                    id: "1",
                    content: testCode
                )
            )
        )
    )
    .padding()
    .frame(height: 300)
}

#Preview("Bot") {
    ChatEntryView(
        model: ChatEntryViewModel(
            content: .chatbot(.init(
                id: "1",
                actions: AsyncThrowingStream(
                    elements: "Hello, how are you?".map { character in ModelAction.appendChunk(String(character)) },
                    delay: .milliseconds(100),
                    initialDelay: .seconds(2)
                )
            ))
        )
    )
    .padding()
}

#Preview("Bot Code") {
    ChatEntryView(
        model: ChatEntryViewModel(
            content: .chatbot(.init(
                id: "1",
                actions: AsyncThrowingStream(
                    elements: testCode.map { character in ModelAction.appendChunk(String(character)) },
                    delay: .milliseconds(100)
                )
            ))
        )
    )
    .padding()
    .frame(height: 300)
}
