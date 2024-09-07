import Chat
import Foundation
import UWP
import WinAppSDK
import WinUI
import WindowsFoundation
import WinSDK
import Observation

@MainActor
final class UserChatEntryView {
    private let viewModel: UserChatEntryViewModel

    init(viewModel: UserChatEntryViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        stackPanel
    }

    private lazy var stackPanel: StackPanel = {
        let stackPanel = StackPanel()
        stackPanel.children.append(border)
        stackPanel.horizontalAlignment = .right
        stackPanel.opacity = 0.7
        return stackPanel
    }()

    private lazy var border: Border = {
        let border = Border()
        border.borderThickness = Thickness(left: 1, top: 1, right: 1, bottom: 1)
        border.borderBrush = SolidColorBrush(Color(a: 128, r: 226, g: 229, b: 233))
        border.background = SolidColorBrush(Color(a: 255, r: 255, g: 255, b: 255))
        border.cornerRadius = CornerRadius(
            topLeft: 12, topRight: 0, bottomRight: 12, bottomLeft: 12)
        border.child = textBlock
        return border
    }()

    private lazy var textBlock: TextBlock = {
        let textBlock = TextBlock()
        textBlock.textWrapping = .wrap
        textBlock.text = viewModel.content
        textBlock.margin = Thickness(left: 16, top: 16, right: 16, bottom: 16)
        return textBlock
    }()
}