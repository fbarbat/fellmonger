import Chat

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

import WinUIExtensions

@MainActor
final class ChatInputView<ViewModel: ChatInputViewModel> {
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        grid
    }

    private lazy var grid: some FrameworkElement = {
        let grid = Grid()
        grid.horizontalAlignment = .stretch

        let textBoxColumn = ColumnDefinition()
        textBoxColumn.width = GridLength(value: 1, gridUnitType: .star)
        grid.columnDefinitions.append(textBoxColumn)

        let buttonColumn = ColumnDefinition()
        buttonColumn.width = GridLength(value: 1, gridUnitType: .auto)
        grid.columnDefinitions.append(buttonColumn)

        grid.children.append(promptTextBox)

        grid.children.append(sendButton)
        Grid.setColumn(sendButton, 1)

        return grid
    }()

    private lazy var promptTextBox: TextBox = {
        let promptTextBox = TextBox()
        promptTextBox.horizontalAlignment = .stretch
        promptTextBox.placeholderText = "Ask anything..."
        promptTextBox.margin = Thickness(left: 0, top: 0, right: 15, bottom: 0)

        promptTextBox.bindText(to: viewModel, \.prompt)

        promptTextBox.keyDown.addHandler { [weak self] a, args in
            guard let self, let args, args.key == .enter else {
                return
            }

            self.viewModel.send()
        }

        promptTextBox.loaded.addHandler { [weak self] _, _ in
            self?.focusTextBox()
        }

        return promptTextBox
    }()

    private func focusTextBox() {
        _ = try? promptTextBox.focus(.programmatic)
    }

    private lazy var sendButton: Button = {
        let sendButton = Button()
        sendButton.style = Application.current?.resources["AccentButtonStyle"] as? Style
        sendButton.click.addHandler { [weak self] _, _ in
            self?.viewModel.mainAction()
        }

        trackLoading(sendButton: sendButton)

        return sendButton
    }()

    private func trackLoading(sendButton: Button) {
        let state = withObservationTracking {
            viewModel.state
        } onChange: {
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                self.trackLoading(sendButton: self.sendButton)
            }
        }

        if let fontIcon = sendButton.content as? FontIcon,
            fontIcon.glyph == state.codeGlyph
        {
            return
        }

        let fontIcon = FontIcon()
        fontIcon.glyph = state.codeGlyph
        sendButton.content = fontIcon
    }
}
extension ChatInputViewModelState {
    fileprivate var codeGlyph: String {
        switch self {
        case .ready:
            // send icon
            return "\u{E724}"
        case .sending:
            // stop icon
            return "\u{E71A}"
        }
    }
}
