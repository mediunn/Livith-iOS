//
//  NotificationEndpoint.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Alamofire

public typealias NotificationService = NetworkService<NotificationEndpoint>

public enum NotificationEndpoint {
    case fetchList(cursor: Int?, size: Int)
    case markAsRead(id: Int)
    case fetchUnreadCount
    case updateConsent(request: DTO.Request.UpdateNotificationConsent)
    case updateMarketingConsent
    case fetchSettings
}

extension NotificationEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchList:
            return "/notifications"
        case .markAsRead(let id):
            return "/notifications/\(id)/read"
        case .fetchUnreadCount:
            return "/notifications/unread-count"
        case .updateConsent:
            return "/notifications/consent"
        case .updateMarketingConsent:
            return "/notifications/marketing-consent"
        case .fetchSettings:
            return "/notifications/settings"
        }
    }

    public var query: [String: Any]? {
        switch self {
        case .fetchList(cursor: let cursor, size: let size):
            var query: [String: Any] = ["size": size]
            if let cursor {
                query["cursor"] = cursor
            }
            return query
        default:
            return .none
        }
    }

    public var body: (any Encodable)? {
        switch self {
        case .updateConsent(request: let request):
            return request
        default:
            return .none
        }
    }

    public var method: LivithNetwork.HTTPMethod {
        switch self {
        case .fetchList, .fetchUnreadCount, .fetchSettings:
            return .get
        case .updateConsent, .updateMarketingConsent:
            return .post
        case .markAsRead:
            return .patch
        }
    }

    public var requiresInterceptor: Bool {
        return true
    }
}
