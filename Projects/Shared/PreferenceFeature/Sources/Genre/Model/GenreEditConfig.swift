//
//  GenreEditConfig.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct GenreEditConfig {
    public let stepIndicator: (current: Int, total: Int)?
    public let navigationTitle: String
    public let title: String
    public let subtitle: String?
    public let submitTitle: String
    
    public init(
        stepIndicator: (current: Int, total: Int)? = nil,
        navigationTitle: String,
        title: String,
        subtitle: String? = nil,
        submitTitle: String
    ) {
        self.stepIndicator = stepIndicator
        self.navigationTitle = navigationTitle
        self.title = title
        self.subtitle = subtitle
        self.submitTitle = submitTitle
    }
}

// MARK: - Factory Methods

public extension GenreEditConfig {
    static func onboarding() -> GenreEditConfig {
        GenreEditConfig(
            stepIndicator: (current: 3, total: 4),
            navigationTitle: "회원가입",
            title: "선호하는 장르를\n3개 선택해 주세요",
            subtitle: "마이페이지에서 언제든 바꿀 수 있어요",
            submitTitle: "다음"
        )
    }
    
    static func home() -> GenreEditConfig {
        GenreEditConfig(
            stepIndicator: (current: 1, total: 2),
            navigationTitle: "취향 선택",
            title: "좋아하는 장르를\n3개 선택해 주세요",
            subtitle: nil,
            submitTitle: "다음"
        )
    }
    
    static func edit() -> GenreEditConfig {
        GenreEditConfig(
            stepIndicator: nil,
            navigationTitle: "장르 변경",
            title: "선호하는 장르를\n3개 선택해 주세요",
            subtitle: nil,
            submitTitle: "변경하기"
        )
    }
}

