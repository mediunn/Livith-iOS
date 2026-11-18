//
//  LoginRoute.swift
//  LoginFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithDesignSystem

enum LoginRoute: Hashable {
    case login
    case terms(TempUser)
    case nickname(SignupSession)
    case preferredGenre(SignupSession)
    case preferredArtist(SignupSession)
}
