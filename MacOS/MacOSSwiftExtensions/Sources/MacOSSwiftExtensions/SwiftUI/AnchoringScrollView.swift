//
//  AnchoringScrollView.swift
//
//
//  Created by Fernando Barbat on 6/6/24.
//

import SwiftUI

import Combine

public struct AnchoringScrollView<Content: View>: View {
    @Binding var anchoredToBottom: Bool
    let content: () -> Content
    let log: ((String) -> Void)?

    @State private var contentFrame: CGRect?
    @State private var containerSize: CGSize?

    @Namespace var anchoringViewID: Namespace.ID

    public init(
        anchoredToBottom: Binding<Bool>,
        content: @escaping () -> Content
    ) {
        self._anchoredToBottom = anchoredToBottom
        self.content = content
        self.log = nil
    }

    fileprivate init(
        anchoredToBottom: Binding<Bool>,
        content: @escaping () -> Content,
        log: @escaping (String) -> Void
    ) {
        self._anchoredToBottom = anchoredToBottom
        self.content = content
        self.log = log
    }

    public var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    content()

                    Color.clear
                        .frame(width: 0, height: 0)
                        .id(anchoringViewID)
                }
                .onChange(of: anchoredToBottom) {
                    guard anchoredToBottom else {
                        return
                    }

                    scrollToBottom(scrollViewProxy: scrollViewProxy)
                }
                .background(
                    GeometryReader { geometryProxy in
                        Color.clear
                            .preference(
                                key: NSRectPreferenceKey.self,
                                value: geometryProxy.frame(in: .scrollView)
                            )
                            .onPreferenceChange(NSRectPreferenceKey.self) { newContentFrame in
                                defer {
                                    contentFrame = newContentFrame
                                }

                                guard
                                    let newContentFrame,
                                    let containerSize
                                else {
                                    return
                                }

                                if contentFrame?.size == newContentFrame.size {
                                    if newContentFrame.maxY <= containerSize.height {
                                        if !anchoredToBottom {
                                            anchoredToBottom = true
                                        }
                                    } else {
                                        if anchoredToBottom {
                                            anchoredToBottom = false
                                        }
                                    }
                                } else {
                                    if anchoredToBottom {
                                        scrollToBottom(scrollViewProxy: scrollViewProxy)
                                    }
                                }

                                log?("Content " + newContentFrame.debugDescription)
                            }
                    }
                )
            }
            .background(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(
                            key: NSSizePreferenceKey.self,
                            value: geometryProxy.size
                        )
                        .onPreferenceChange(NSSizePreferenceKey.self) { newContainerSize in
                            defer {
                                containerSize = newContainerSize
                            }

                            guard
                                let newContainerSize,
                                let contentFrame
                            else {
                                return
                            }

                            if containerSize == nil {
                                anchoredToBottom = contentFrame.maxY <= newContainerSize.height
                            }

                            if anchoredToBottom {
                                scrollToBottom(scrollViewProxy: scrollViewProxy)
                            }

                            log?("Container " + newContainerSize.debugDescription)
                        }
                }
            )
        }
    }

    private func scrollToBottom(scrollViewProxy: ScrollViewProxy) {
        scrollViewProxy.scrollTo(anchoringViewID, anchor: .bottom)
    }
}

private struct NSRectPreferenceKey: PreferenceKey {
    static let defaultValue: NSRect? = nil

    static func reduce(value: inout NSRect?, nextValue: () -> NSRect?) {
        value = nextValue()
    }
}

private struct NSSizePreferenceKey: PreferenceKey {
    static let defaultValue: NSSize? = nil

    static func reduce(value: inout NSSize?, nextValue: () -> NSSize?) {
        value = nextValue()
    }
}

private struct TestAnchoringScrollView: View {
    @State private var text = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia odio vitae vestibulum vestibulum. In ac magna sed turpis mollis auctor sed vitae turpis. Integer quis risus ultrices, ornare nisi sed, porttitor ligula. Aliquam cursus nisi neque, et porttitor ipsum ullamcorper nec. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla facilisi. Aenean luctus non magna ac suscipit. Integer nec odio sapien. Curabitur ac enim nunc. Fusce aliquet quam odio, sit amet ornare sapien ullamcorper a. Duis nec felis tellus. Aliquam sit amet est pharetra, dictum dolor id, congue velit. Morbi faucibus, tellus nec molestie aliquam, velit nulla lacinia eros, vitae tincidunt libero tortor non ante.
    """

    @State private var log = ""

    @State private var anchoredToBottom = true

    var body: some View {
        VStack {
            AnchoringScrollView(
                anchoredToBottom: $anchoredToBottom,
                content: {
                    Text(text)
                },
                log: { entry in
                    log += "\(entry)\n"
                }
            )
            .padding()

            Button("Duplicate text") {
                log += "Duplicated text\n"
                text += text
            }

            TextEditor(text: .constant(log))
        }
        .frame(width: 400, height: 400)
    }
}

#Preview {
    TestAnchoringScrollView()
}
