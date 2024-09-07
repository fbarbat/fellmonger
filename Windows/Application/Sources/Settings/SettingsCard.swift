import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

/// Partial implementation of 
/// https://learn.microsoft.com/en-us/dotnet/communitytoolkit/windows/settingscontrols/settingscard
/// in Swift.
final class SettingsCard {
    private let header: String
    private let description: String
    private let content: FrameworkElement

    init(
        header: String,
        description: String,
        content: FrameworkElement
    ) {
        self.header = header
        self.description = description
        self.content = content
    }

    var view: some FrameworkElement {
        border
    }

    private lazy var border: Border = {
        let border = Border()
        border.borderThickness = Thickness(left: 1, top: 1, right: 1, bottom: 1)
        border.borderBrush = Application.current.resources["CardStrokeColorDefaultBrush"] as? Brush
        border.background = Application.current.resources["CardBackgroundFillColorDefaultBrush"] as? Brush
        border.cornerRadius = CornerRadius(
            topLeft: 4, topRight: 4, bottomRight: 4, bottomLeft: 4)
        border.padding = Thickness(left: 16, top: 16, right: 16, bottom: 16)
        border.minWidth = 148
        border.minHeight = 68
        border.child = grid
        return border
    }()

    private lazy var grid: Grid = {
        let grid = Grid()
        
        let verticalStackPanelColumnDefinition = ColumnDefinition()
        verticalStackPanelColumnDefinition.width = GridLength(value: 1, gridUnitType: .star)
        grid.columnDefinitions.append(verticalStackPanelColumnDefinition)

        let contentColumnDefinition = ColumnDefinition()
        contentColumnDefinition.width = GridLength(value: 1, gridUnitType: .auto)
        grid.columnDefinitions.append(contentColumnDefinition)

        Grid.setColumn(textBlocksStackPanel, 0)
        grid.children.append(textBlocksStackPanel)

        Grid.setColumn(contentStackPanel, 1)
        grid.children.append(contentStackPanel)
        return grid
    }()

    private lazy var textBlocksStackPanel: StackPanel = {
        let textBlocksStackPanel = StackPanel()
        textBlocksStackPanel.horizontalAlignment = .stretch
        textBlocksStackPanel.children.append(headerTextBlock)
        textBlocksStackPanel.children.append(descriptionTextBlock)
        return textBlocksStackPanel
    }()

    private lazy var headerTextBlock: TextBlock = {
        let headerTextBlock = TextBlock()
        headerTextBlock.horizontalAlignment = .stretch
        headerTextBlock.text = header
        headerTextBlock.textWrapping = .wrap
        return headerTextBlock
    }()

        private lazy var descriptionTextBlock: TextBlock = {
        let descriptionTextBlock = TextBlock()
        descriptionTextBlock.horizontalAlignment = .stretch
        descriptionTextBlock.text = description
        descriptionTextBlock.fontSize = 12
        descriptionTextBlock.foreground = Application.current.resources["TextFillColorSecondaryBrush"] as? Brush
        descriptionTextBlock.textWrapping = .wrap
        return descriptionTextBlock
    }()

    private lazy var contentStackPanel: StackPanel = {
        let contentStackPanel = StackPanel()
        contentStackPanel.maxWidth = 200
        contentStackPanel.verticalAlignment = .center
        contentStackPanel.children.append(content)
        return contentStackPanel
    }()
}