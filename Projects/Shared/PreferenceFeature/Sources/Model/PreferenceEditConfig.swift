//
//  PreferenceEditConfig.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/6/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct PreferenceEditConfig {
    public let navigationTitle: String
    public let stepIndicator: (current: Int, total: Int)?
    public let showSubtitle: Bool
    public let submitTitle: String
    
    public init(
        navigationTitle: String,
        stepIndicator: (current: Int, total: Int)? = nil,
        showSubtitle: Bool = false,
        submitTitle: String
    ) {
        self.navigationTitle = navigationTitle
        self.stepIndicator = stepIndicator
        self.showSubtitle = showSubtitle
        self.submitTitle = submitTitle
    }
}

// MARK: - Artist Factory Methods

public extension PreferenceEditConfig {
    static func artistOnboarding() -> PreferenceEditConfig {
        PreferenceEditConfig(
            navigationTitle: "회원가입",
            stepIndicator: (current: 4, total: 4),
            showSubtitle: true,
            submitTitle: "가입 완료"
        )
    }
    
    static func artistHome() -> PreferenceEditConfig {
        PreferenceEditConfig(
            navigationTitle: "취향 선택",
            stepIndicator: (current: 2, total: 2),
            showSubtitle: false,
            submitTitle: "취향 선택 완료"
        )
    }
    
    static func artistEdit() -> PreferenceEditConfig {
        PreferenceEditConfig(
            navigationTitle: "아티스트 변경",
            stepIndicator: nil,
            showSubtitle: false,
            submitTitle: "변경하기"
        )
    }
}

// MARK: - Genre Factory Methods

public extension PreferenceEditConfig {
    static func genreOnboarding() -> PreferenceEditConfig {
        PreferenceEditConfig(
            navigationTitle: "회원가입",
            stepIndicator: (current: 3, total: 4),
            showSubtitle: true,
            submitTitle: "다음"
        )
    }
    
    static func genreHome() -> PreferenceEditConfig {
        PreferenceEditConfig(
            navigationTitle: "취향 선택",
            stepIndicator: (current: 1, total: 2),
            showSubtitle: false,
            submitTitle: "다음"
        )
    }
    
    static func genreEdit() -> PreferenceEditConfig {
        PreferenceEditConfig(
            navigationTitle: "장르 변경",
            stepIndicator: nil,
            showSubtitle: false,
            submitTitle: "변경하기"
        )
    }
}
