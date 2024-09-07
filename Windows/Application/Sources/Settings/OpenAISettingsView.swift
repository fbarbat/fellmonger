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
final class OpenAISettingsView {
    private let viewModel: OpenAISettingsViewModel

    init(viewModel: OpenAISettingsViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        return settingSection.view
    }

    private lazy var settingSection = SettingsSection(
        title: "OpenAI",
        cards: [
            keyCard,
            modelCard
        ]
    )

    private lazy var keyCard = SettingsCard(
        header: "Key", 
        description: "The key to access OpenAI servers.", 
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
        description: "The identifier of the OpenAI model. Check OpenAI docs for model identifiers.",
        content: modelTextBox
    )

    private lazy var modelTextBox: TextBox = {
        let modelTextBox = TextBox()
        modelTextBox.text = viewModel.model
        #bindText(modelTextBox, to: viewModel, \.model)
        return modelTextBox
    }()
}