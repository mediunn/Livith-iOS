//
//  NotificationConsentResult.swift
//  Domain
//
//  Created by Youjin Lee on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct NotificationConsentResult {
    public let sender: String
    public let agreedAt: String
    public let message: String

    public init(sender: String, agreedAt: String, message: String) {
        self.sender = sender
        self.agreedAt = agreedAt
        self.message = message
    }
}
