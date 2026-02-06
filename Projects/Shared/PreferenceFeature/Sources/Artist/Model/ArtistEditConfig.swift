//
//  ArtistEditConfig.swift
//  PreferenceFeature
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

public struct ArtistEditConfig {
    public let initialSelection: [PreferredArtist]
    public let stepIndicator: (current: Int, total: Int)?
    public let navigationTitle: String
    public let showSubtitle: Bool
    public let submitTitle: String
    
    public init(
        initialSelection: [PreferredArtist] = [],
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

public extension ArtistEditConfig {
    static func onboarding() -> ArtistEditConfig {
        ArtistEditConfig(
            stepIndicator: (current: 4, total: 4),
            navigationTitle: "회원가입",
            showSubtitle: true,
            submitTitle: "가입 완료"
        )
    }
    
    static func home() -> ArtistEditConfig {
        ArtistEditConfig(
            stepIndicator: (current: 2, total: 2),
            navigationTitle: "취향 선택",
            showSubtitle: false,
            submitTitle: "취향 선택 완료"
        )
    }
    
    static func edit(selectedArtists: [PreferredArtist]) -> ArtistEditConfig {
        ArtistEditConfig(
            initialSelection: selectedArtists,
            stepIndicator: nil,
            navigationTitle: "아티스트 변경",
            showSubtitle: false,
            submitTitle: "변경하기"
        )
    }
}
