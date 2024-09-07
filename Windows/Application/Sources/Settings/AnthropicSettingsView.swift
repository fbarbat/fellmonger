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
final class AnthropicSettingsView {
    private let viewModel: AnthropicSettingsViewModel

    init(viewModel: AnthropicSettingsViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        return settingSection.view
    }

    private lazy var settingSection = SettingsSection(
        title: "Anthropic",
        cards: [
            keyCard,
            modelCard
        ]
    )

    private lazy var keyCard = SettingsCard(
        header: "Key", 
        description: "The key to access Anthropic servers.", 
        content: keyPasswordBox
    )

    private lazy var keyPasswordBox: PasswordBox = {
        let keyPasswordBox = PasswordBox()
        keyPasswordBox.password = viewModel.key

        keyPasswordBox.passwordChanged.addHandler { [weak self] _, _ in
            guard let self else {
                return
            }

            self.viewModel.key = self.keyPasswordBox.password
        }
        
        return keyPasswordBox
    }()

    private lazy var modelCard = SettingsCard(
        header: "Model",
        description: "The identifier of the Anthropic model. Check Anthropic docs for model identifiers.",
        content: modelTextBox
    )

    private lazy var modelTextBox: TextBox = {
        let modelTextBox = TextBox()
        modelTextBox.text = viewModel.model
        #bindText(modelTextBox, to: viewModel, \.model)
        return modelTextBox
    }()
}