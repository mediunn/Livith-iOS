//
//  CheckNicknameDuplicate.swift
//  OnboardingData
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 34. 닉네임 중복 확인

import Foundation

import LivithNetwork

public extension DTO.Response {
    struct CheckNicknameDuplicate: Decodable {
        let available: Bool
    }
}
