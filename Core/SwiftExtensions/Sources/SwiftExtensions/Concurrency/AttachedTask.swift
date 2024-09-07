//
//  AttachedTask.swift
//
//
//  Created by Fernando Barbat on 31/5/24.
//

import Foundation

/// A task whose lifecycle is tied to its owner's lifecycle.
/// Task creation and execution are separated. This is useful for breaking reference cycles, such as 
/// when initializing tasks in `init` methods that hold references to `self`.
/// The task is automatically canceled when the attached task is deinitialized.
public actor AttachedTask<Success, Failure>: Sendable where Success: Sendable, Failure: Error {
    private var task: Task<Success, Failure>?
    
    /// Used when we need to wait for the current task because it hasn't started yet
    private var taskContinuations: [CheckedContinuation<Task<Success, Failure>, Never>] = []

    public init() {}
    
    deinit {
        task?.cancel()
    }

    public nonisolated func cancel() {
        Task {
            await doCancel()
        }
    }

    private func doCancel() {
        task?.cancel()
    }
}

public extension AttachedTask where Failure == Error {
    nonisolated func run(operation: @escaping (@Sendable () async throws -> Success)) {
        Task {
            await doRun(operation: operation)
        }
    }

    private func doRun(operation: @escaping (@Sendable () async throws -> Success)) {
        let task = Task(operation: operation)
        self.task = task
        
        taskContinuations.forEach { continuation in
            continuation.resume(returning: task)
        }
        taskContinuations.removeAll()
    }
    
    var value: Success {
        get async throws {
            if let task {
                return try await task.value
            }
            
            let task = await withCheckedContinuation { continuation in
                taskContinuations.append(continuation)
            }
            
            return try await task.value
        }
    }
}

public extension AttachedTask where Failure == Never {
    nonisolated func run(operation: @escaping (@Sendable () async -> Success)) {
        Task {
            await doRun(operation: operation)
        }
    }

    private func doRun(operation: @escaping (@Sendable () async -> Success)) {
        let task = Task(operation: operation)
        self.task = task
        
        taskContinuations.forEach { continuation in
            continuation.resume(returning: task)
        }
        taskContinuations.removeAll()
    }
    
    var value: Success {
        get async {
            if let task {
                return await task.value
            }
            
            let task = await withCheckedContinuation { continuation in
                taskContinuations.append(continuation)
            }
            
            return await task.value
        }
    }
}

// TODO: Implement more Task methods as needed
