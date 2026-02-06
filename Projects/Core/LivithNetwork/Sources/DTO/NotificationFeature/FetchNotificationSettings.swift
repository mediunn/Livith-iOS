//
//  FetchNotificationSettings.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 알림 설정 조회

public extension DTO.Response {
    struct FetchNotificationSettings: Decodable {
        public let benefitAlert: Bool
        public let nightAlert: Bool
        public let ticketAlert: Bool
        public let infoAlert: Bool
        public let interestAlert: Bool
        public let recommendAlert: Bool
    }
}
