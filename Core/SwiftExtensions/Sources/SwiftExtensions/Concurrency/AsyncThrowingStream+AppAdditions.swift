//
//  AsyncThrowingStream+AppAdditions.swift
//
//
//  Created by Fernando Barbat on 5/6/24.
//

import Foundation

public extension AsyncThrowingStream where Failure == Error, Element: Sendable {
    init(
        elements: [Element],
        delay: ContinuousClock.Instant.Duration = .zero,
        initialDelay: ContinuousClock.Instant.Duration = .zero,
        bufferingPolicy limit: AsyncThrowingStream<Element, Failure>.Continuation.BufferingPolicy = .unbounded
    ) {
        let (asyncThrowingStream, continuation) = Self.makeStream(bufferingPolicy: limit)

        Task {
            do {
                try await Task.sleep(for: initialDelay)
                for element in elements {
                    try await Task.sleep(for: delay)
                    continuation.yield(element)
                }
            } catch {
            }
            
            continuation.finish()
        }
        
        self = asyncThrowingStream
    }
}
