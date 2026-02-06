//
//  UserEndpoint.swift
//  LivithNetwork
//
//  Created by 김진웅 on 2026/01/21.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Alamofire

public typealias UserService = NetworkService<UserEndpoint>

public enum UserEndpoint {
    case logout(request: DTO.Request.RequestLogout)
    case checkNicknameDuplicate(nickname: String)
    case updateUserNickname(request: DTO.Request.UpdateUserNickname)
    case withdraw(request: DTO.Request.DeleteUser)
    case updateNotificationConsent(request: DTO.Request.UpdateNotificationConsent)
    case updateMarketingConsent
    case fetchNotificationSettings
    case fetchNotificationList(cursor: Int?, size: Int)
    case markNotificationAsRead(id: Int)
    case fetchUnreadNotificationCount
}

extension UserEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .logout:
            return "/auth/logout"
        case .checkNicknameDuplicate:
            return "/users/check-nickname"
        case .updateUserNickname:
            return "/users/nickname"
        case .withdraw:
            return "/auth/withdraw"
        case .updateNotificationConsent:
            return "/notifications/consent"
        case .updateMarketingConsent:
            return "/notifications/marketing-consent"
        case .fetchNotificationSettings:
            return "/notifications/settings"
        case .fetchNotificationList:
            return "/notifications"
        case .markNotificationAsRead(let id):
            return "/notifications/\(id)/read"
        case .fetchUnreadNotificationCount:
            return "/notifications/unread-count"
        }
    }

    public var query: [String : Any]? {
        switch self {
        case .checkNicknameDuplicate(nickname: let nickname):
            return ["nickname" : nickname]
        case .fetchNotificationList(cursor: let cursor, size: let size):
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
        case .logout(request: let request):
            return request
        case .updateUserNickname(request: let request):
            return request
        case .withdraw(request: let request):
            return request
        case .updateNotificationConsent(request: let request):
            return request
        default:
            return .none
        }
    }
    
    public var method: LivithNetwork.HTTPMethod {
        switch self {
        case .logout, .withdraw, .updateNotificationConsent, .updateMarketingConsent:
            return .post
        case .checkNicknameDuplicate, .fetchNotificationSettings, .fetchNotificationList, .fetchUnreadNotificationCount:
            return .get
        case .updateUserNickname, .markNotificationAsRead:
            return .patch
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .logout, .checkNicknameDuplicate:
            return false
        case .updateUserNickname, .withdraw, .updateNotificationConsent, .updateMarketingConsent,
             .fetchNotificationSettings, .fetchNotificationList, .markNotificationAsRead, .fetchUnreadNotificationCount:
            return true
        }
    }
}
