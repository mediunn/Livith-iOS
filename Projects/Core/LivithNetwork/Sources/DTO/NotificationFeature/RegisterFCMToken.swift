//
//  RegisterFCMToken.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 2/7/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public extension DTO.Request {
    struct RegisterFCMToken: Encodable {
        let token: String

        public init(token: String) {
            self.token = token
        }
    }

    struct DeleteFCMToken: Encodable {
        let token: String

        public init(token: String) {
            self.token = token
        }
    }
}
