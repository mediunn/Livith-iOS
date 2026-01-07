//
//  SocialAuthenticator.swift
//  SocialAuth
//
//  Created by 김진웅 on 1/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

protocol SocialAuthenticator {
    func signIn() async throws(SocialAuthError) -> SocialAuthCredential
}
