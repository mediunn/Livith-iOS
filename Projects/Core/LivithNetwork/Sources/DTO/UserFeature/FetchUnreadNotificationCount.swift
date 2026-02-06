//
//  FetchUnreadNotificationCount.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 읽지 않은 알림 개수 조회

public extension DTO.Response {
    struct FetchUnreadNotificationCount: Decodable {
        public let unreadCount: Int
    }
}
