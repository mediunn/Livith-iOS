//
//  NotificationAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum NotificationAPI {
    public static func fetchList(cursor: Int?, size: Int) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "size", value: String(size))
        ]
        if let cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: String(cursor)))
        }
        return NetworkEndpoint(
            path: "/notifications",
            method: .get,
            task: .query(queryItems),
            authentication: .required
        )
    }

    public static func markAsRead(id: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/\(id)/read",
            method: .patch,
            task: .plain,
            authentication: .required
        )
    }

    /// 관심 콘서트 결과 알림 목록. POST 호출 자체가 서버의 노출 완료 처리를 겸한다.
    public static func fetchEntryAlerts() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/entry-alerts",
            method: .post,
            task: .plain,
            authentication: .required
        )
    }

    public static func markAllAsRead() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/read-all",
            method: .patch,
            task: .plain,
            authentication: .required
        )
    }

    public static func fetchUnreadCount() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/unread-count",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func updateConsent(field: String, isAgreed: Bool) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/consent",
            method: .post,
            task: .body(DTO.Request.UpdateNotificationConsent(field: field, isAgreed: isAgreed)),
            authentication: .required
        )
    }

    public static func updateMarketingConsent() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/marketing-consent",
            method: .post,
            task: .plain,
            authentication: .required
        )
    }

    public static func fetchSettings() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/settings",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func registerFCMToken(token: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/fcm-token",
            method: .post,
            task: .body(DTO.Request.RegisterFCMToken(token: token)),
            authentication: .required
        )
    }

    public static func deleteFCMToken(token: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/notifications/fcm-token",
            method: .delete,
            task: .body(DTO.Request.DeleteFCMToken(token: token)),
            authentication: .required
        )
    }
}
