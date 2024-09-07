import Chat

import Foundation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

@MainActor
final class MainView {
    private let viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    let titleBar = TitleBarView()

    var view: some FrameworkElement {
        grid
    }

    private lazy var grid: Grid = {
        let grid = Grid()

        let titleBarRow = RowDefinition()
        titleBarRow.height = GridLength(value: 1, gridUnitType: .auto)
        grid.rowDefinitions.append(titleBarRow)

        let contentRow = RowDefinition()
        contentRow.height = GridLength(value: 1, gridUnitType: .star)
        grid.rowDefinitions.append(contentRow)

        grid.children.append(titleBar.view)

        Grid.setRowSpan(navigationView, 2)
        grid.children.append(navigationView)

        return grid
    }()

    private lazy var navigationView: NavigationView = {
        let navigationView = NavigationView()
        navigationView.isPaneOpen = false
        navigationView.isBackButtonVisible = .collapsed

        navigationView.footerMenuItems.append(clearChatButton)

        navigationView.selectedItem = chatNavigationViewItem
        navigationView.menuItems.append(chatNavigationViewItem)
        navigationView.content = view(for: chatNavigationViewItem)

        Application.current.resources["NavigationViewContentMargin"] = "0,48,0,0"
        Application.current.resources["NavigationViewMinimalContentMargin"] = "0,48,0,0"
        Application.current.resources["NavigationViewContentGridBorderThickness"] = "1,1,0,0"
        Application.current.resources["NavigationViewContentGridCornerRadius"] = "8,0,0,0"

        navigationView.selectionChanged.addHandler { [weak self] _, args in
            guard
                let self,
                let args,
                let selectedItem = args.selectedItem as? NavigationViewItem
            else {
                return
            }

            self.navigationView.content = self.view(for: selectedItem)
        }

        navigationView.itemInvoked.addHandler { [weak self] _, args in
            guard
                let self,
                let args,
                args.invokedItemContainer == self.clearChatButton
            else {
                return
            }

            self.viewModel.reset()
        }

        return navigationView
    }()

    private lazy var chatNavigationViewItem: NavigationViewItem = {
        let icon = FontIcon()
        icon.glyph = "\u{E8BD}"

        let chatNavigationViewItem = NavigationViewItem()
        chatNavigationViewItem.icon = icon
        chatNavigationViewItem.content = "Chat"
        chatNavigationViewItem.tag = "chat"

        return chatNavigationViewItem
    }()

    private lazy var settingsNavigationViewItem: NavigationViewItem = {
        navigationView.settingsItem as! NavigationViewItem
    }()

    private lazy var clearChatButton: NavigationViewItem = {
        let icon = FontIcon()
        icon.glyph = "\u{E74D}"

        let clearChatButton = NavigationViewItem()
        clearChatButton.icon = icon
        clearChatButton.content = "Clear chat"
        clearChatButton.tag = "clearChat"
        clearChatButton.selectsOnInvoked = false

        return clearChatButton
    }()

    private func view(for item: NavigationViewItem) -> FrameworkElement {
        switch item {
        case chatNavigationViewItem:
            return chatView.view
        case settingsNavigationViewItem:
            return settingsView.view
        default:
            return settingsView.view
        }
    }

    private lazy var chatView = ChatView(viewModel: viewModel.chatViewModel)

    private lazy var settingsView = SettingsView(viewModel: viewModel.settingsViewModel)
}
