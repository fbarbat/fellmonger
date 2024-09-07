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
final class GeneralSettingsView {
    private let viewModel: GeneralSettingsViewModel

    init(viewModel: GeneralSettingsViewModel) {
        self.viewModel = viewModel
    }

    var view: some FrameworkElement {
        return settingSection.view
    }

    private lazy var settingSection = SettingsSection(
        title: "General",
        cards: [
            activeModelCard
        ]
    )

    private lazy var activeModelCard = SettingsCard(
        header: "Active Model", 
        description: "The LLM model that will be used next time you send a prompt.", 
        content: activeModelComboBox
    )

    private lazy var activeModelComboBox: ComboBox = {
        let comboBox = ComboBox()

        GeneralSettingsViewModelActiveModel.allCases.forEach { activeModel in
            comboBox.items.append(activeModel.label)
        }

        comboBox.selectedItem = viewModel.activeModel.label

        comboBox.selectionChanged.addHandler { [weak self] _, _ in
            guard  let self else {
                return
            }

            let selectedIndex = self.activeModelComboBox.selectedIndex

            guard 
                selectedIndex >= 0, 
                selectedIndex < GeneralSettingsViewModelActiveModel.allCases.count else {
                return
            }

            self.viewModel.activeModel =  GeneralSettingsViewModelActiveModel.allCases[Int(selectedIndex)]
        }

        return comboBox
    }()
}