//
//  GenreEditConfig.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

enum GenreEditConfig {
    case onboarding
    case home
    case edit

    var stepIndicator: (current: Int, total: Int)? {
        switch self {
        case .onboarding:
            return (current: 3, total: 4)
        case .home:
            return (current: 1, total: 2)
        case .edit:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .onboarding, .home:
            return "취향 선택"
        case .edit:
            return "장르 변경"
        }
    }
    
    var submitTitle: String {
        switch self {
        case .onboarding, .home:
            return "다음"
        case .edit:
            return "장르 변경하기"
        }
    }
}
