//
//  GenreEditConfig.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 1/29/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

public struct GenreEditConfig {
    public let initialSelection: [PreferredGenre]
    public let navigationTitle: String
    public let stepIndicator: (current: Int, total: Int)?
    public let showSubtitle: Bool
    public let submitTitle: String
    
    public init(
        initialSelection: [PreferredGenre] = [],
        navigationTitle: String,
        stepIndicator: (current: Int, total: Int)? = nil,
        showSubtitle: Bool = false,
        submitTitle: String
    ) {
        self.initialSelection = initialSelection
        self.navigationTitle = navigationTitle
        self.stepIndicator = stepIndicator
        self.showSubtitle = showSubtitle
        self.submitTitle = submitTitle
    }
}

// MARK: - Factory Methods

public extension GenreEditConfig {
    static func onboarding() -> GenreEditConfig {
        GenreEditConfig(
            navigationTitle: "회원가입",
            stepIndicator: (current: 3, total: 4),
            showSubtitle: true,
            submitTitle: "다음"
        )
    }
    
    static func home() -> GenreEditConfig {
        GenreEditConfig(
            navigationTitle: "취향 선택",
            stepIndicator: (current: 1, total: 2),
            submitTitle: "다음"
        )
    }
    
    static func edit(selectedGenres: [PreferredGenre]) -> GenreEditConfig {
        GenreEditConfig(
            initialSelection: selectedGenres,
            navigationTitle: "장르 변경",
            submitTitle: "변경하기"
        )
    }
}
