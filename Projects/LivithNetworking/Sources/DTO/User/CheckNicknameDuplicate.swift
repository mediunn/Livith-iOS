//
//  CheckNicknameDuplicate.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 34. 닉네임 중복 확인

import Foundation

public extension DTO.Response {
    struct CheckNicknameDuplicate: Decodable {
        public let available: Bool
    }
}
