//
//  AuthService.swift
//  Auth
//
//  Created by 김진웅 on 12/4/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol AuthService {
    func login() async throws(AuthError) -> AuthCredential
}
