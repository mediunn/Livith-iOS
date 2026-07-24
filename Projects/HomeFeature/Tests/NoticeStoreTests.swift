//
//  NoticeStoreTests.swift
//  HomeFeatureTests
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Testing

@testable import HomeFeature
import DIContainer
import Domain

@MainActor
struct NoticeStoreTests {

    // MARK: - Properties

    let container: MockDIContainer

    // MARK: - Initializer

    init() {
        self.container = MockDIContainer()
        self.container.registerDependencies()
    }

    // MARK: - Tests

    @Test("전체 읽기 성공 시 모든 알림을 읽음 상태로 갱신해야 한다")
    func 전체_읽기_성공_시_모든_알림을_읽음_상태로_갱신해야_한다() async throws {
        // Given
        container.notificationRepository.notificationListStub = [
            makeNotificationItem(id: 1, isRead: false),
            makeNotificationItem(id: 2, isRead: true),
            makeNotificationItem(id: 3, isRead: false)
        ]
        let sut = NoticeStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()

        // When
        sut.send(.markAllAsRead)
        try await waitForAsyncTask()

        // Then
        #expect(container.notificationRepository.markAllNotificationsAsReadCallCount == 1)
        #expect(sut.state.notifications.allSatisfy { $0.isRead })
        #expect(sut.state.notifications.map(\.id) == [1, 2, 3])
    }

    @Test("전체 읽기 실패 시 알림 읽음 상태를 유지해야 한다")
    func 전체_읽기_실패_시_알림_읽음_상태를_유지해야_한다() async throws {
        // Given
        container.notificationRepository.notificationListStub = [
            makeNotificationItem(id: 1, isRead: false),
            makeNotificationItem(id: 2, isRead: true)
        ]
        let sut = NoticeStore()
        sut.send(.onAppear)
        try await waitForAsyncTask()
        container.notificationRepository.markAllNotificationsAsReadErrorStub = .serverError

        // When
        sut.send(.markAllAsRead)
        try await waitForAsyncTask()

        // Then
        #expect(container.notificationRepository.markAllNotificationsAsReadCallCount == 1)
        #expect(sut.state.notifications.map(\.isRead) == [false, true])
    }
}

// MARK: - Helpers

private extension NoticeStoreTests {
    func waitForAsyncTask() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    func makeNotificationItem(id: Int, isRead: Bool) -> NotificationItem {
        NotificationItem(
            id: id,
            type: .interestConcert,
            title: "알림 \(id)",
            content: "내용 \(id)",
            targetID: nil,
            isRead: isRead,
            createdAt: Date()
        )
    }
}
