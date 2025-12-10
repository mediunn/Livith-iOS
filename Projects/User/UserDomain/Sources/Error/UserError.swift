//
//  UserError.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum UserError: LocalizedError {
    case networkError
    case serverError
    case invalidResponse
    case unknown
}
