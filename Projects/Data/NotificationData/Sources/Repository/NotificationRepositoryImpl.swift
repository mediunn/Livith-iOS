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
