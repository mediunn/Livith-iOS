//
//  UpdateToken.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 29. 토큰 재발급

import Foundation

public extension DTO.Request {
    struct UpdateToken: Decodable {
        public let accessToken: String
    }
}
