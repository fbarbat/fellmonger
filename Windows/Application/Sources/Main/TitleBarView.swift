import Foundation
import WinUI
import WindowsFoundation

@MainActor
final class TitleBarView {
    var view: some FrameworkElement {
        border
    }

    private lazy var border: Border = {
        let border = Border()
        border.height = 48
        border.margin = Thickness(left: 48, top: 0, right: 0, bottom: 0)
        border.child = stackPanel
        border.verticalAlignment = .stretch
        border.isHitTestVisible = true
        return border
    }()

    private lazy var stackPanel: StackPanel = {
        let stackPanel = StackPanel()
        stackPanel.verticalAlignment = .stretch
        stackPanel.orientation = .horizontal
        stackPanel.children.append(icon)
        stackPanel.children.append(title)
        return stackPanel
    }()

    private lazy var icon: Image = {
        let path = Bundle.module.path(forResource: "icon_16", ofType: "png")!

        let bitmapImage = BitmapImage()
        bitmapImage.uriSource = Uri(path)

        let image = Image()
        image.source = bitmapImage
        image.stretch = .none

        return image
    }()

    private lazy var title: TextBlock = {
        let title = TextBlock()
        title.margin = Thickness(left: 12, top: 0, right: 0, bottom: 0)
        title.verticalAlignment = .center
        title.style = Application.current.resources["CaptionTextBlockStyle"] as? Style
        title.text = "Fellmonger"
        return title
    }()
}