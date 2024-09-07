import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BindTextMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {

        var iterator = node.arguments.makeIterator()
        
        guard let targetExpression = iterator.next()?.expression else {
            fatalError("Expected targetExpression")
        }

        guard let sourceExpression = iterator.next()?.expression else {
            fatalError("Expected sourceExpression")
        }

        guard let sourcePropertyExpression = iterator.next()?.expression else {
            fatalError("Expected sourcePropertyExpression")
        }

        return """
        {
            nonisolated(unsafe) let source = \(raw: sourceExpression.description)
            nonisolated(unsafe) let target = \(raw: targetExpression.description)
            nonisolated(unsafe) var track: (@MainActor () -> Void)! 
            
            track = { @MainActor in
                let sourceValue = withObservationTracking {
                    source[keyPath: \(raw: sourcePropertyExpression.description)]
                } onChange: {
                    Task { @MainActor [weak source, weak target] in
                        guard
                            let source,
                            let target
                        else {
                            return
                        }
                        
                        track()
                    }
                }

                guard target.text != sourceValue else {
                    return
                }

                target.text = sourceValue
            }

            track()

            target.textChanged.addHandler({ [weak source, weak target] _, _ in
                guard 
                    let source,
                    let target
                else {
                    return
                }

                let targetValue = target.text

                guard source[keyPath: \(raw: sourcePropertyExpression.description)] != targetValue else {
                    return
                }

                source[keyPath: \(raw: sourcePropertyExpression.description)] = targetValue
            })
        }()
        """
    }
}

@main
struct WinUIExtensionsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BindTextMacro.self,
    ]
}
