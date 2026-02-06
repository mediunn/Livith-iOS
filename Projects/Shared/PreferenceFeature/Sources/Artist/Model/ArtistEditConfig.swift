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
    public let navigationTitle: String
    public let stepIndicator: (current: Int, total: Int)?
    public let showSubtitle: Bool
    public let submitTitle: String
    
    public init(
        initialSelection: [PreferredArtist] = [],
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

public extension ArtistEditConfig {
    static func onboarding() -> ArtistEditConfig {
        ArtistEditConfig(
            navigationTitle: "회원가입",
            stepIndicator: (current: 4, total: 4),
            showSubtitle: true,
            submitTitle: "가입 완료"
        )
    }
    
    static func home() -> ArtistEditConfig {
        ArtistEditConfig(
            navigationTitle: "취향 선택",
            stepIndicator: (current: 2, total: 2),
            submitTitle: "취향 선택 완료"
        )
    }
    
    static func edit(selectedArtists: [PreferredArtist]) -> ArtistEditConfig {
        ArtistEditConfig(
            initialSelection: selectedArtists,
            navigationTitle: "아티스트 변경",
            submitTitle: "변경하기"
        )
    }
}
