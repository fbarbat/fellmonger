//
//  ChatInputView.swift
//
//
//  Created by Fernando Barbat on 1/6/24.
//

import SwiftUI

import MacOSSwiftExtensions
import Chat

@MainActor
struct ChatInputView: View {
    @BindableProtocol var model: ChatInputViewModel

    enum FocusedField {
        case prompt
    }

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        HStack(alignment: .center) {
            TextField("Ask anything…", text: $model.prompt, axis: .vertical)
                .lineLimit(5)
                .textFieldStyle(.plain)
                .focused($focusedField, equals: .prompt)
                .onAppear {
                    focusedField = .prompt
                }
                .onSubmit {
                    model.send()
                }
                .padding(9)

            Button(
                action: {
                    model.mainAction()
                },
                label: {
                    let actionImageName = actionImageName
                    Image(systemName: actionImageName)
                        .foregroundColor(Color(nsColor: .controlAccentColor))
                        .font(.title)
                        .padding(.trailing, 3)
                        .animation(.bouncy, value: actionImageName)
                }
            )
            .buttonStyle(.plain)
        }
        .background(
            Color(nsColor: .controlColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 1)
        )
        .padding(.bottom, 5)
    }

    private var actionImageName: String {
        switch model.state {
        case .sending:
            return "stop.circle.fill"
        case .ready:
            return "arrow.up.circle.fill"
        }
    }
}

@MainActor
private struct TestChatInputView: View {
    @State var model = ChatInputViewModel()

    @State private var entries: [(Date, String)] = []

    var body: some View {
        VStack {
            ChatInputView(model: model)

            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(entries, id: \.0) { entry in
                            Text(entry.1)
                        }
                    }
                    Spacer()
                }
            }
            .defaultScrollAnchor(.bottom)
        }
        .padding()
        .onAppear {
            model.onSubmitted = { prompt in
                entries.append((Date(), prompt))
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }
}

#Preview {
    TestChatInputView()
}
