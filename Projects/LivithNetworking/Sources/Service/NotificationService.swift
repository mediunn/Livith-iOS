//
//  NotificationService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - NotificationService

public protocol NotificationService: Sendable {
    func fetchList(cursor: Int?, size: Int) async throws(NetworkError) -> [DTO.Response.FetchNotificationList]
    func markAsRead(id: Int) async throws(NetworkError)
    func fetchUnreadCount() async throws(NetworkError) -> DTO.Response.FetchUnreadNotificationCount
    func updateConsent(field: String, isAgreed: Bool) async throws(NetworkError) -> DTO.Response.UpdateNotificationConsent
    func updateMarketingConsent() async throws(NetworkError) -> DTO.Response.UpdateNotificationConsent
    func fetchSettings() async throws(NetworkError) -> DTO.Response.FetchNotificationSettings
    func registerFCMToken(token: String) async throws(NetworkError)
    func deleteFCMToken(token: String) async throws(NetworkError)
}

// MARK: - NotificationServiceImpl

struct NotificationServiceImpl: NotificationService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchList(cursor: Int?, size: Int) async throws(NetworkError) -> [DTO.Response.FetchNotificationList] {
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "size", value: String(size))]
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: String(cursor)))
        }
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications",
                method: .get,
                task: .query(queryItems),
                authentication: .required
            )
        )
    }

    public func markAsRead(id: Int) async throws(NetworkError) {
        let _: EmptyResponse = try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/\(id)/read",
                method: .patch,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func fetchUnreadCount() async throws(NetworkError) -> DTO.Response.FetchUnreadNotificationCount {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/unread-count",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func updateConsent(field: String, isAgreed: Bool) async throws(NetworkError) -> DTO.Response.UpdateNotificationConsent {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/consent",
                method: .post,
                task: .body(DTO.Request.UpdateNotificationConsent(field: field, isAgreed: isAgreed)),
                authentication: .required
            )
        )
    }

    public func updateMarketingConsent() async throws(NetworkError) -> DTO.Response.UpdateNotificationConsent {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/marketing-consent",
                method: .post,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func fetchSettings() async throws(NetworkError) -> DTO.Response.FetchNotificationSettings {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/settings",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func registerFCMToken(token: String) async throws(NetworkError) {
        let _: EmptyResponse = try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/fcm-token",
                method: .post,
                task: .body(DTO.Request.RegisterFCMToken(token: token)),
                authentication: .required
            )
        )
    }

    public func deleteFCMToken(token: String) async throws(NetworkError) {
        let _: EmptyResponse = try await networkClient.request(
            NetworkEndpoint(
                path: "/notifications/fcm-token",
                method: .delete,
                task: .body(DTO.Request.DeleteFCMToken(token: token)),
                authentication: .required
            )
        )
    }
}
