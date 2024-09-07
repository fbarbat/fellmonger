//
//  Test.swift
//  Settings
//
//  Created by Fernando Barbat on 7/8/24.
//

import Settings
import Testing
import SettingsMacros

@MainActor
struct Test {
    @Test
    func defaultValue() async throws {
        let settingsApplicationModel = makeSettingsService()
        #expect(settingsApplicationModel.get(#stringKeyPath(\.openAI.key)) == "")
    }

    @Test
    func setGet() async throws {
        let settingsApplicationModel = makeSettingsService()
        settingsApplicationModel.set(#stringKeyPath(\.openAI.key), value: "1")
        #expect(settingsApplicationModel.get(#stringKeyPath(\.openAI.key)) == "1")
    }

    @Test
    func onChange() async throws {
        let settingsApplicationModel = makeSettingsService()
        let stream = settingsApplicationModel.onChange(of: #stringKeyPath(\.openAI.key))
        settingsApplicationModel.set(#stringKeyPath(\.openAI.key), value: "2")
        var iterator = stream.makeAsyncIterator()
        let value = await iterator.next()
        #expect(value == "2")
    }

    private func makeSettingsService() -> SettingsApplicationModel {
        SettingsApplicationModel { _ in }
    }
}
