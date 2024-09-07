import Settings

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

import Settings

@MainActor
final class SettingsSection {
    private let title: String
    private let cards: [SettingsCard]

    init(title: String, cards: [SettingsCard]) {
        self.title = title
        self.cards = cards
    }

    var view: some FrameworkElement {
        return stackPanel
    }

    private lazy var stackPanel: StackPanel = {
        let stackPanel = StackPanel()
        stackPanel.spacing = 4
        stackPanel.children.append(titleTextBlock)
        cards.forEach { card in
            stackPanel.children.append(card.view)
        }
        return stackPanel
    }()

    private lazy var titleTextBlock: TextBlock = {
        let titleTextBlock = TextBlock()
        titleTextBlock.text = title
        titleTextBlock.style = Application.current.resources["BodyStrongTextBlockStyle"] as? Style
        titleTextBlock.margin = Thickness(left: 1, top: 30, right: 0, bottom: 6)
        return titleTextBlock
    }()
}