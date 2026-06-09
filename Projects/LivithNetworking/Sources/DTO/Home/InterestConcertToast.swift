//
//  InterestConcertToast.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 46. 관심 코너트 토스트 노출 여부 조회 / 47. 관심 콘서트 토스트 노출 처리

import Foundation

public extension DTO.Response {
    struct FetchInterestConcertToast: Decodable {
        public let needsToShow: Bool
        public let type: ToastType?

        public enum ToastType: String, Decodable {
            case canceled = "CANCELED"
            case completed = "COMPLETED"
            case both = "BOTH"
        }
    }

    struct UpdateInterestConcertToast: Decodable {
        public let success: Bool
    }
}
