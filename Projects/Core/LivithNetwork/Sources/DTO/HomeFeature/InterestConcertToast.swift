//
//  InterestConcertToast.swift
//  LivithNetwork
//
//  Created by 김진웅 on 5/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 관심 콘서트 토스트

public extension DTO.Response {
    struct FetchInterestConcertToast: Decodable {
        public let needsToShow: Bool
    }

    struct UpdateInterestConcertToast: Decodable {
        public let success: Bool
    }
}
