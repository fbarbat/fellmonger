import UWP
import WinAppSDK
import WinUI
import WindowsFoundation
import WinSDK
import Observation

@MainActor
public extension TextBlock {
    /// One way binding for the text property to the source property.
    /// In other words, only changes on the source side are propagated to the text property.
    /// It doesn't support protocols (existential types) as source.
    func bindText<S: AnyObject>(
        to source: S, 
        _ sourceProperty: KeyPath<S, String>
        ) {
        bindToObservable(
            source: source,
            sourceProperty: sourceProperty,
            target: self,
            targetProperty: \.text
        )
    }
}

@MainActor
public extension TextBox {
    /// Two-way binding for the text property to the source property.
    /// In other words, changes on each side will be propagated to the other side.
    /// It doesn't support protocols (existential types) as source. #bindText macro can be used in that case.
    func bindText<S: AnyObject>(to source: S, _ property: ReferenceWritableKeyPath<S, String>) {
        bindTwoWay(
            source: source,
            sourceProperty: property,
            target: self,
            targetProperty: \.text,
            targetPropertyChangeEvent: \.textChanged
        ) { handler in
            { _, _ in
                handler()
            }
        }
    }
}

/// Generic implementation for two-way binding for FrameworkElements
@MainActor
private func bindTwoWay<F: FrameworkElement, P: Equatable, S: AnyObject, E>(
    source: S,
    sourceProperty: ReferenceWritableKeyPath<S, P>,
    target: F,
    targetProperty: ReferenceWritableKeyPath<F, P>,
    targetPropertyChangeEvent: KeyPath<F, Event<E>>,
    targetPropertyChangeEventHandlerFactory: (@escaping () -> Void) -> E
) {
    bindToObservable(
        source: source,
        sourceProperty: sourceProperty,
        target: target,
        targetProperty: targetProperty
    )

    bindToFrameworkElement(
        source: source,
        sourceProperty: sourceProperty,
        target: target,
        targetProperty: targetProperty,
        targetPropertyChangeEvent: targetPropertyChangeEvent,
        targetPropertyChangeEventHandlerFactory: targetPropertyChangeEventHandlerFactory
    )
}

@MainActor
private func bindToObservable<T: FrameworkElement, P: Equatable, S: AnyObject>(
    source: S,
    sourceProperty: KeyPath<S, P>,
    target: T,
    targetProperty: ReferenceWritableKeyPath<T, P>
) {
    nonisolated(unsafe) let source = source
    nonisolated(unsafe) let sourceProperty = sourceProperty
    nonisolated(unsafe) let target = target
    nonisolated(unsafe) let targetProperty = targetProperty

    let sourceValue = withObservationTracking {
        source[keyPath: sourceProperty]
    } onChange: {
        Task { @MainActor [weak source, weak target] in
            guard
                let source,
                let target
            else {
                return
            }
            
            bindToObservable(
                source: source,
                sourceProperty: sourceProperty,
                target: target,
                targetProperty: targetProperty
            )
        }
    }

    guard target[keyPath: targetProperty] != sourceValue else {
        return
    }

    target[keyPath: targetProperty] = sourceValue
}

@MainActor
private func bindToFrameworkElement<F: FrameworkElement, P: Equatable, S: AnyObject, E>(
    source: S,
    sourceProperty: ReferenceWritableKeyPath<S, P>,
    target: F,
    targetProperty: ReferenceWritableKeyPath<F, P>,
    targetPropertyChangeEvent: KeyPath<F, Event<E>>,
    targetPropertyChangeEventHandlerFactory: (@escaping () -> Void) -> E
) {
    target[keyPath: targetPropertyChangeEvent].addHandler(
        targetPropertyChangeEventHandlerFactory { [weak source, weak target] in
            guard 
                let source,
                let target
            else {
                return
            }

            let targetValue = target[keyPath: targetProperty]

            guard source[keyPath: sourceProperty] != targetValue else {
                return
            }

            source[keyPath: sourceProperty] = targetValue
        }
    )
}
