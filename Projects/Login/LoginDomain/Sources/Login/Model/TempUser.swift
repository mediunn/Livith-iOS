//
//  TempUser.swift
//  LoginDomain
//
//  Created by 김진웅 on 12/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct TempUser {
    public let provider: SocialLoginProvider
    public let providerID: String
    public let email: String?
    
    public init(provider: SocialLoginProvider, providerID: String, email: String?) {
        self.provider = provider
        self.providerID = providerID
        self.email = email
    }
}
