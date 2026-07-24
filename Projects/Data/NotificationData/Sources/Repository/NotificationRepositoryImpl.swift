//
//  NotificationRepositoryImpl.swift
//  NotificationData
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetworking
import Persistence

struct NotificationRepositoryImpl: NotificationRepository {
    private let networkClient: NetworkClient
    private let userdefaultsStorage: UserDefaultsStorage
    private let mapper: NotificationMapper = .init()
    private let errorMapper: NotificationErrorMapper = .init()

    init(
        networkClient: NetworkClient,
        userdefaultsStorage: UserDefaultsStorage
    ) {
        self.networkClient = networkClient
        self.userdefaultsStorage = userdefaultsStorage
    }

    func fetchNotificationList(cursor: Int?, size: Int) async throws(NotificationError) -> [NotificationItem] {
        do {
            let response: [DTO.Response.FetchNotificationList] = try await networkClient.request(
                NotificationAPI.fetchList(cursor: cursor, size: size)
            )
            return response.map { mapper.toDomain(from: $0) }
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func markNotificationAsRead(id: Int) async throws(NotificationError) {
        do {
            try await networkClient.request(
                NotificationAPI.markAsRead(id: id)
            )
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func fetchEntryAlerts() async throws(NotificationError) -> [InterestEntryAlert] {
        #if DEBUG
        // 스킴 "Livith-iOS-EntryAlertsTest" 실행 시(STUB_ENTRY_ALERTS 런치 인자) 실 서버 대신 스텁 반환.
        if ProcessInfo.processInfo.arguments.contains("STUB_ENTRY_ALERTS") {
            return Self.debugEntryAlertStubList
        }
        #endif
        do {
            let response: DTO.Response.FetchEntryAlerts = try await networkClient.request(
                NotificationAPI.fetchEntryAlerts()
            )
            return mapper.toDomain(from: response)
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func markAllNotificationsAsRead() async throws(NotificationError) {
        do {
            try await networkClient.request(
                NotificationAPI.markAllAsRead()
            )
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func fetchUnreadNotificationCount() async throws(NotificationError) -> Int {
        do {
            let response: DTO.Response.FetchUnreadNotificationCount = try await networkClient.request(
                NotificationAPI.fetchUnreadCount()
            )
            return response.unreadCount
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(NotificationError) -> NotificationConsentResult {
        do {
            let response: DTO.Response.UpdateNotificationConsent = try await networkClient.request(
                NotificationAPI.updateConsent(field: field.rawValue, isAgreed: isAgreed)
            )
            updateUserAuthority { user in
                switch field {
                case .benefitAlert:
                    user.authority.benefitNotification = isAgreed
                case .nightAlert:
                    user.authority.nightNotification = isAgreed
                case .ticketAlert:
                    user.authority.ticketSchedule = isAgreed
                case .infoAlert:
                    user.authority.concertInfoUpdate = isAgreed
                case .interestAlert:
                    user.authority.favoriteArtistConcert = isAgreed
                case .recommendAlert:
                    user.authority.preferenceBasedConcert = isAgreed
                }
            }
            return mapper.toDomain(from: response)
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func updateMarketingConsent() async throws(NotificationError) -> NotificationConsentResult {
        do {
            let response: DTO.Response.UpdateNotificationConsent = try await networkClient.request(
                NotificationAPI.updateMarketingConsent()
            )
            updateUserAuthority { user in
                user.authority.marketingConsent = true
            }
            return mapper.toDomain(from: response)
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    private func updateUserAuthority(_ transform: (inout User) -> Void) {
        guard var user: User = try? userdefaultsStorage.fetch(for: .currentUser) else { return }
        transform(&user)
        try? userdefaultsStorage.save(user, for: .currentUser)
    }

    #if DEBUG
    /// FR-06 결과 시트 UI 확인용 스텁. 자동 정리 2건 + 요청 결과 3건 = 5건.
    static let debugEntryAlertStubList: [InterestEntryAlert] = [
        InterestEntryAlert(
            kind: .autoRemovedCompleted,
            title: "자동 정리된 공연 3",
            content: "원 오크 록 내한 공연 외 2건이 자동 정리 됐어요",
            concertID: nil
        ),
        InterestEntryAlert(
            kind: .autoRemovedCanceled,
            title: "취소된 공연 1",
            content: "원 오크 록 내한 공연이 취소되어 자동 정리 됐어요",
            concertID: nil
        ),
        InterestEntryAlert(
            kind: .requestRegistered,
            title: "테일러 스위프트 내한 콘서트",
            content: "나의 관심 콘서트에 추가됐어요",
            concertID: 1
        ),
        InterestEntryAlert(
            kind: .requestFailed,
            title: "오아시스 내한 공연",
            content: "정확한 정보가 부족하여 추가되지 않았어요",
            concertID: nil
        ),
        InterestEntryAlert(
            kind: .requestFailed,
            title: "콜드플레이 지난 공연",
            content: "지난 공연으로 관심 콘서트에 추가되지 않았어요",
            concertID: nil
        )
    ]
    #endif

    func fetchNotificationSettings() async throws(NotificationError) -> NotificationSettings {
        do {
            let response: DTO.Response.FetchNotificationSettings = try await networkClient.request(
                NotificationAPI.fetchSettings()
            )
            return mapper.toDomain(from: response)
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func registerFCMToken(_ token: String) async throws(NotificationError) {
        do {
            try await networkClient.request(
                NotificationAPI.registerFCMToken(token: token)
            )
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }

    func deleteFCMToken(_ token: String) async throws(NotificationError) {
        do {
            try await networkClient.request(
                NotificationAPI.deleteFCMToken(token: token)
            )
        } catch {
            let notificationError: NotificationError = errorMapper.mapToNotificationError(error)
            throw notificationError
        }
    }
}
