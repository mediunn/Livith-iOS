//
//  CheckInterestedConcert.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 44. 유저의 관심 콘서트 여부 확인

import Foundation

public extension DTO.Response {
    struct CheckInterestedConcert: Decodable {
        public let isInterested: Bool
    }
}
