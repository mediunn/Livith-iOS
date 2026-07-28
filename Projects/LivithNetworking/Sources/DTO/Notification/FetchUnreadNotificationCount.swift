//
//  FetchUnreadNotificationCount.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 49. 읽지 않은 알림 개수 조회

import Foundation

public extension DTO.Response {
    struct FetchUnreadNotificationCount: Decodable {
        public let unreadCount: Int
    }
}
