//
//  FetchNotificationSettings.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 44. 알림 설정 조회

import Foundation

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
