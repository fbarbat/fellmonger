import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SettingsMacrosImplementations)
import SettingsMacrosImplementations

let testMacros: [String: Macro.Type] = [
    "stringKeyPath": StringKeyPathMacro.self,
]
#endif

final class MyMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(SettingsMacrosImplementations)
        assertMacroExpansion(
            #"""
            #stringKeyPath(\.ollama.url)
            """#,
            expandedSource: #"""
            StringKeyPath(keyPath: \.ollama.url, stringKeyPath: #"\.ollama.url"#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
