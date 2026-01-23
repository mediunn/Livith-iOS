//
//  SocialLoginProvider.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum SocialLoginProvider: CustomStringConvertible {
    case apple
    case kakao
    
    public var description: String {
        switch self {
        case .apple:
            return "apple"
        case .kakao:
            return "kakao"
        }
    }
}
