//
//  DiscardableTask.swift
//  HomeFeature
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct DiscardableTask: Sendable {
    static let none = DiscardableTask(task: nil)

    private let task: Task<Void, Never>?

    init(task: Task<Void, Never>?) {
        self.task = task
    }

    func wait() async {
        await withTaskCancellationHandler {
            await task?.value
        } onCancel: {
            task?.cancel()
        }
    }
}
