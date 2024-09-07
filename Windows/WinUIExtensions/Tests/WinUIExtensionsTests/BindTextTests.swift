import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(WinUIExtensionsMacrosImplementations)
import WinUIExtensionsMacrosImplementations

let testMacros: [String: Macro.Type] = [
    "bindText": BindTextMacro.self,
]
#endif

final class BindTextMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(WinUIExtensionsMacrosImplementations)
        // TODO: Macro tests don't work on Windows so it's not implemented
        assertMacroExpansion(
            #"""
            #bindText(textBox, to: viewModel, \.textProperty)
            """#,
            expandedSource: #"""
            TODO
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
