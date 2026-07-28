//
//  RequestConcert.swift
//  LivithNetworking
//
//  Created by Youjin Lee on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 63. 콘서트 정보 요청

import Foundation

public extension DTO.Request {
    struct RequestConcert: Encodable {
        public let title: String
        public let url: String?
        public let autoRegister: Bool
        public let requestContent: String?

        public init(
            title: String,
            url: String?,
            autoRegister: Bool,
            requestContent: String?
        ) {
            self.title = title
            self.url = url
            self.autoRegister = autoRegister
            self.requestContent = requestContent
        }
    }
}
