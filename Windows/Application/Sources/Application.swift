import Chat

import Foundation

import Settings

import UWP

import WinAppSDK

import WinSDK

import WinUI

import WindowsFoundation

@main
@MainActor
final class Application: SwiftApplication {
    /// A required initializer for the application. Non-UI setup for your application can be done here.
    /// Subscribing to unhandledException is a good place to handle any unhandled exceptions that may occur
    /// in your application.
    public required init() {
        super.init()
        unhandledException.addHandler { (_, args: UnhandledExceptionEventArgs!) in
            print("Unhandled exception: \(args.message)")
        }
    }

    /// onShutdown is called once Application.start returns. This is a good place to do any cleanup
    /// that is necessary for your application before it terminates.
    nonisolated override public func onShutdown() {}

    /// onLaunched is called when the application is launched. This is the main entry point for your
    /// application and when you can create a window and display UI.s
    nonisolated override public func onLaunched(_ args: WinUI.LaunchActivatedEventArgs) {
        // Ideally, the delegate method should be on the MainActor itself.
        // assumeIsolated won't compile here
        nonisolated(unsafe) let application = self

        Task { @MainActor in
            application.mainWindow.activate()
        }
    }

    private lazy var mainWindow = MainWindow(
        mainViewModel: mainViewModel
    )

    private lazy var mainViewModel = MainViewModel(
        chatViewModel: chatModule.chatViewModel,
        settingsViewModel: settingsModule.settingsViewModel
    )

    private lazy var chatModule = ChatModule(
        settingsModule: settingsModule
    )

    private lazy var settingsModule = SettingsModule(
        configurationPersistenceService: WindowsRegistryConfigurationPersistenceService()
    )
}
