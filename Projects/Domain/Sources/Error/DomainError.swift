//
//  DomainError.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol DomainError: LocalizedError {
    static func from(message: String) -> Self
}
