//
//  Nickname.swift
//  Domain
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Nickname: Hashable {
    
    // MARK: - Constants
    
    private static let pattern = "^[a-zA-Z0-9가-힣]{1,10}$"
    
    // MARK: - Properties
    
    public let value: String
    
    // MARK: - Initializer
    
    public init(_ value: String) throws {
        guard !value.isEmpty else {
            throw AuthError.emptyNickname
        }
        
        guard let regex = try? Regex(Self.pattern),
              value.wholeMatch(of: regex) != nil 
        else {
            throw AuthError.invalidNickname
        }
        
        self.value = value
    }
}
