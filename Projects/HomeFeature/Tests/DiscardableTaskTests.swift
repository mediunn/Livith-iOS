//
//  DiscardableTaskTests.swift
//  HomeFeatureTests
//
//  Copyright © 2026 Livith. All rights reserved.
//

import Testing

@testable import HomeFeature

@MainActor
struct DiscardableTaskTests {

    @Test("wait 중 취소되면 내부 Task도 cancel해야 한다")
    func wait_중_취소되면_내부_Task도_cancel해야_한다() async throws {
        let inner = Task<Void, Never> {
            if (try? await Task.sleep(nanoseconds: 2_000_000_000)) == nil { return }
        }
        let handle = DiscardableTask(task: inner)
        let waiter = Task {
            await handle.wait()
        }

        try await Task.sleep(nanoseconds: 50_000_000)
        waiter.cancel()
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(inner.isCancelled)
    }

    @Test("none wait는 즉시 반환해야 한다")
    func none_wait는_즉시_반환해야_한다() async {
        await DiscardableTask.none.wait()
    }

    @Test("내부 Task 완료 시 wait도 반환해야 한다")
    func 내부_Task_완료_시_wait도_반환해야_한다() async {
        let inner = Task { }
        let handle = DiscardableTask(task: inner)
        await handle.wait()
        #expect(!inner.isCancelled)
    }
}
