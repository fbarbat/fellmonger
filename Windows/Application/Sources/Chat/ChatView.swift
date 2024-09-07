import Chat

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

@MainActor
final class ChatView {
    private let viewModel: ChatViewModel

    private var chatEntryViewModels: [ChatEntryViewModel] = []
    private var chatEntryViews: [ChatEntryView] = []

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        return grid
    }

    private lazy var grid: Grid = {
        let grid = Grid()
        grid.horizontalAlignment = .stretch
        grid.verticalAlignment = .stretch

        let chatRow = RowDefinition()
        chatRow.height = GridLength(value: 1, gridUnitType: .star)
        grid.rowDefinitions.append(chatRow)

        let inputRow = RowDefinition()
        inputRow.height = GridLength(value: 1, gridUnitType: .auto)
        grid.rowDefinitions.append(inputRow)

        grid.children.append(scrollView)

        grid.children.append(chatInputViewArea)
        Grid.setRow(chatInputViewArea, 1)

        return grid
    }()

    private lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.content = stackPanel
        scrollView.verticalAnchorRatio = 1
        trackAnchoredToBottom(scrollView: scrollView)
        return scrollView
    }()

    private func trackAnchoredToBottom(scrollView: ScrollView) {
        let anchoredToBottom = withObservationTracking {
            viewModel.anchoredToBottom
        } onChange: {
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                self.trackAnchoredToBottom(scrollView: self.scrollView)
            }
        }

        // We need to delay the scroll to bottom so all the offsets are properly computed
        Task { @MainActor in
            if anchoredToBottom {
                _ = try! scrollView.scrollTo(
                    scrollView.horizontalOffset,
                    scrollView.scrollableHeight,
                    ScrollingScrollOptions(.disabled, .ignore)
                )
            }
        }
    }

    private lazy var stackPanel: StackPanel = {
        let stackPanel = StackPanel()
        stackPanel.orientation = .vertical
        stackPanel.spacing = 10
        stackPanel.horizontalAlignment = .stretch
        stackPanel.margin = Thickness(left: 15, top: 15, right: 15, bottom: 0)
        trackEntries(stackPanel: stackPanel)
        return stackPanel
    }()

    private func trackEntries(stackPanel: StackPanel) {
        let chatEntryViewModels = withObservationTracking {
            viewModel.entries
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                self.trackEntries(stackPanel: self.stackPanel)
            }
        }

        let difference = chatEntryViewModels.difference(from: self.chatEntryViewModels) {
            $0.id == $1.id
        }

        for change in difference {
            updateViews(change: change, stackPanel: stackPanel)
        }
    }

    private func updateViews(change: CollectionDifference<ChatEntryViewModel>.Change, stackPanel: StackPanel) {
        switch change {
        case let .remove(offset, _, _):
            _ = stackPanel.children.remove(at: offset)
            chatEntryViews.remove(at: offset)
            chatEntryViewModels.remove(at: offset)

        case let .insert(offset, chatEntryViewModel, _):
            chatEntryViewModels.insert(chatEntryViewModel, at: offset)
            let chatEntryView = ChatEntryView(viewModel: chatEntryViewModel)
            chatEntryViews.insert(chatEntryView, at: offset)
            stackPanel.children.insertAt(UInt32(offset), chatEntryView.view)
        }
    }

    private lazy var chatInputViewArea: Border = {
        let border = Border()
        border.child = chatInputView.view
        border.margin = Thickness(left: 15, top: 15, right: 15, bottom: 15)
        return border
    }()

    private lazy var chatInputView = ChatInputView(viewModel: viewModel.chatInputViewModel)
}
