import Settings

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

@MainActor
final class SettingsView {
    private let viewModel: any SettingsViewModel

    init(viewModel: any SettingsViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        grid
    }

    private lazy var grid: Grid = {
        let grid = Grid()
        grid.padding = Thickness(left: 36, top: 14, right: 0, bottom: 0)

        let titleRow = RowDefinition()
        titleRow.height = GridLength(value: 1, gridUnitType: .auto)
        grid.rowDefinitions.append(titleRow)

        let contentRow = RowDefinition()
        contentRow.height = GridLength(value: 1, gridUnitType: .star)
        grid.rowDefinitions.append(contentRow)

        grid.children.append(title)

        Grid.setRow(scrollView, 1)
        grid.children.append(scrollView)
        
        return grid
    }()

    private lazy var title: TextBlock = {
        let title = TextBlock()
        title.text = "Settings"
        title.style = Application.current.resources["TitleTextBlockStyle"] as? Style
        return title
    }()

    private lazy var scrollView: ScrollView = {
        let scrollView = ScrollView()
        scrollView.content = sections
        return scrollView
    }()

    private lazy var sections: StackPanel = {
        let sections = StackPanel()
        sections.margin = Thickness(left: 0, top: 0, right: 36, bottom: 0)
        sections.children.append(generalSettingsView.view)
        sections.children.append(ollamaSettingsView.view)
        sections.children.append(openAISettingsView.view)
        sections.children.append(anthropicSettingsView.view)
        return sections
    }()

    private lazy var generalSettingsView = GeneralSettingsView(viewModel: viewModel.general)
    private lazy var ollamaSettingsView = OllamaSettingsView(viewModel: viewModel.ollama)
    private lazy var openAISettingsView = OpenAISettingsView(viewModel: viewModel.openAI)
    private lazy var anthropicSettingsView = AnthropicSettingsView(viewModel: viewModel.anthropic)

}