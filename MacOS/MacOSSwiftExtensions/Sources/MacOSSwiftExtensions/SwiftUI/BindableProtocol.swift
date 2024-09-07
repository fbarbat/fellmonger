//
//  BindableProtocol.swift
//
//
//  Created by Fernando Barbat on 1/6/24.
//

import SwiftUI

/// Bindable, but works for protocols as well.
/// Prefer to use Bindable whenever possible since that is standard SwiftUI. But you can use this when using protocols if you want to avoid using generics on the view.
@propertyWrapper
public struct BindableProtocol<T> {
    @dynamicMemberLookup
    public struct Wrapper {
        private let wrappedValue: T

        init(wrappedValue: T) {
            self.wrappedValue = wrappedValue
        }

        public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<T, Property>)
            -> Binding<Property>
        {
            Binding(
                get: { self.wrappedValue[keyPath: keyPath] },
                set: { self.wrappedValue[keyPath: keyPath] = $0 }
            )
        }
    }

    public var wrappedValue: T

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }

    public var projectedValue: Wrapper {
        return Wrapper(wrappedValue: wrappedValue)
    }
}

extension BindableProtocol.Wrapper: @unchecked Sendable {}

extension KeyPath: @unchecked @retroactive Sendable {}
