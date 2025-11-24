//
//  OnboardingRepository.swift
//  OnboardingDomain
//
//  Created by 김진웅 on 11/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol OnboardingRepository {
    func checkNicknameDuplicate(_ nickname: String) async throws(OnboardingError) -> Bool
    func signup(nickname: String) async throws(OnboardingError)
}
