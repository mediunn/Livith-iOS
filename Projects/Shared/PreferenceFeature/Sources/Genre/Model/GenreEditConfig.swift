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
    
    var navigationTitle: String {
        switch self {
        case .onboarding:
            return "회원가입"
        case .home:
            return "취향 선택"
        case .edit:
            return "장르 변경"
        }
    }
    
    var title: String {
        switch self {
        case .onboarding, .edit:
            return "선호하는 장르를\n3개 선택해 주세요"
        case .home:
            return "좋아하는 장르를\n3개 선택해 주세요"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .onboarding:
            return "마이페이지에서 언제든 바꿀 수 있어요"
        case .home, .edit:
            return nil
        }
    }
    
    var submitTitle: String {
        switch self {
        case .onboarding, .home:
            return "다음"
        case .edit:
            return "변경하기"
        }
    }
}
