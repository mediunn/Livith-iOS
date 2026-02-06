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
    public let stepIndicator: (current: Int, total: Int)?
    public let navigationTitle: String
    public let showSubtitle: Bool
    public let submitTitle: String
    
    public init(
        initialSelection: [PreferredGenre] = [],
        stepIndicator: (current: Int, total: Int)? = nil,
        navigationTitle: String,
        showSubtitle: Bool,
        submitTitle: String
    ) {
        self.initialSelection = initialSelection
        self.stepIndicator = stepIndicator
        self.navigationTitle = navigationTitle
        self.showSubtitle = showSubtitle
        self.submitTitle = submitTitle
    }
}

// MARK: - Factory Methods

public extension GenreEditConfig {
    static func onboarding() -> GenreEditConfig {
        GenreEditConfig(
            stepIndicator: (current: 3, total: 4),
            navigationTitle: "회원가입",
            showSubtitle: true,
            submitTitle: "다음"
        )
    }
    
    static func home() -> GenreEditConfig {
        GenreEditConfig(
            stepIndicator: (current: 1, total: 2),
            navigationTitle: "취향 선택",
            showSubtitle: false,
            submitTitle: "다음"
        )
    }
    
    static func edit(selectedGenres: [PreferredGenre]) -> GenreEditConfig {
        GenreEditConfig(
            initialSelection: selectedGenres,
            stepIndicator: nil,
            navigationTitle: "장르 변경",
            showSubtitle: false,
            submitTitle: "변경하기"
        )
    }
}
