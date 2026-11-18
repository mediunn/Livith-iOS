//
//  TempUser.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct TempUser: Hashable {
    public let provider: SocialLoginProvider
    public let providerID: String
    public let email: String?
    
    public init(provider: SocialLoginProvider, providerID: String, email: String?) {
        self.provider = provider
        self.providerID = providerID
        self.email = email
    }
}
