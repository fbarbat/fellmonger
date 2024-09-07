import WinUI
import Observation

/// Binds the `text` property of a `TextBox` to a `String` property in a view model.
/// This macro is used instead of a generic function to support binding to protocol properties,
/// which is useful when the view model implementation is hidden behind a protocol.
@freestanding(expression)
public macro bindText<S>(_ target: TextBox, to viewModel: S, _ property: KeyPath<S, String>) = 
    #externalMacro(module: "WinUIExtensionsMacrosImplementations", type: "BindTextMacro")

