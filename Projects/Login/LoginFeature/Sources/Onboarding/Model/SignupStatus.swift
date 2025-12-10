//
//  SignupStatus.swift
//  LoginFeature
//
//  Created by 김진웅 on 11/24/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

enum SignupStatus: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}
