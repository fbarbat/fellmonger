import Settings

import Foundation

import Observation

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

import Settings

import WinUIExtensionsMacros

@MainActor
final class OllamaSettingsView {
    private let viewModel: OllamaSettingsViewModel

    init(viewModel: OllamaSettingsViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        return settingSection.view
    }

    private lazy var settingSection = SettingsSection(
        title: "Ollama",
        cards: [
            urlCard,
            modelCard
        ]
    )

    private lazy var urlCard = SettingsCard(
        header: "URL", 
        description: "The URL to access the Ollama server.", 
        content: urlTextBox
    )

    private lazy var urlTextBox: TextBox = {
        let urlTextBox = TextBox()
        urlTextBox.text = viewModel.url
        #bindText(urlTextBox, to: viewModel, \.url)
        return urlTextBox
    }()

    private lazy var modelCard = SettingsCard(
        header: "Model",
        description: "The identifier of the Ollama model. Check Ollama docs for model identifiers.",
        content: modelTextBox
    )

    private lazy var modelTextBox: TextBox = {
        let modelTextBox = TextBox()
        modelTextBox.text = viewModel.model
        #bindText(modelTextBox, to: viewModel, \.model)
        return modelTextBox
    }()
}
