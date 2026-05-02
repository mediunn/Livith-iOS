//
//  CheckInterestedConcert.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - 관심 콘서트 여부 확인

public extension DTO.Response {
    struct CheckInterestedConcert: Decodable {
        public let isInterested: Bool
    }
}
