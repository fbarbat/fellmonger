import Chat

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

@MainActor
final class ChatbotChatEntryView {
    private let viewModel: ChatbotChatEntryViewModel

    init(viewModel: ChatbotChatEntryViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        stackPanel
    }

    private lazy var stackPanel: StackPanel = {
        let stackPanel = StackPanel()
        stackPanel.children.append(border)
        stackPanel.horizontalAlignment = .left
        return stackPanel
    }()

    private lazy var border: Border = {
        let border = Border()
        border.borderThickness = Thickness(left: 1, top: 1, right: 1, bottom: 1)
        border.borderBrush = SolidColorBrush(Color(a: 128, r: 226, g: 229, b: 233))
        border.background = SolidColorBrush(Color(a: 255, r: 255, g: 255, b: 255))
        border.cornerRadius = CornerRadius(topLeft: 0, topRight: 12, bottomRight: 12, bottomLeft: 12)
        border.padding = Thickness(left: 16, top: 16, right: 16, bottom: 16)
        trackLoading(border: border)
        return border
    }()

    private func trackLoading(border: Border) {
        let shouldShowProgressRing = withObservationTracking {
            viewModel.state == .loading && viewModel.text.isEmpty
        } onChange: {
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                self.trackLoading(border: self.border)
            }
        }

        if shouldShowProgressRing {
            if !(border.child is ProgressRing) {
                border.child = makeProgressRing()
            }
        } else {
            if !(border.child is TextBlock) {
                border.child = textBlock
            }
        }
    }

    private func makeProgressRing() -> ProgressRing {
        let progressRing = ProgressRing()
        progressRing.width = 16
        progressRing.height = 16
        return progressRing
    }

    private lazy var textBlock: TextBlock = {
        let textBlock = TextBlock()
        textBlock.textWrapping = .wrap
        textBlock.bindText(to: viewModel, \.text)
        return textBlock
    }()
}
