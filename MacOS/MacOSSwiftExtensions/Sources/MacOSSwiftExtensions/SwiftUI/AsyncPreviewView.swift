//
//  AsyncPreviewView.swift
//  Fellmonger
//
//  Created by Fernando Barbat on 10/5/24.
//

import SwiftUI

/// Utility view to show asynchronously created views in previews
public struct AsyncPreviewView<T: View>: View {
    private let viewFactory: @MainActor () async throws -> T
    
    public init(viewFactory: @escaping @MainActor () async throws -> T) {
        self.viewFactory = viewFactory
    }

    @State private var view: T?

    public var body: some View {
        Group {
            if let view {
                view
            } else {
                ProgressView()
                    .task {
                        do {
                            view = try await viewFactory()
                        } catch {
                            // TODO: Show error
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
