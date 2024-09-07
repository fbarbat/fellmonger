import Foundation
import UWP
import WinAppSDK
import WinUI
import WindowsFoundation
import WinSDK
import Chat

@MainActor
final class MainWindow {
    private let mainViewModel: MainViewModel

    init(mainViewModel: MainViewModel){
        self.mainViewModel = mainViewModel
    }

    func activate() {
        try! window.activate()
    }

    private lazy var window: Window = {
        let window = Window()
        window.title = "Fellmonger"
        window.extendsContentIntoTitleBar = true
        window.content = mainView.view
        window.systemBackdrop = MicaBackdrop()
        try! window.setTitleBar(mainView.titleBar.view)

        try! window.appWindow.resize(SizeInt32(width: 900, height: 600))

        return window
    }()

    private lazy var mainView: MainView = MainView(viewModel: mainViewModel)
}