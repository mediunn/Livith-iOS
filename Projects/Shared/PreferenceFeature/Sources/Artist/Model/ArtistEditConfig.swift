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
    public let title: String
    public let subtitle: String?
    public let submitTitle: String
    
    public init(
        initialSelection: [PreferredArtist] = [],
        stepIndicator: (current: Int, total: Int)? = nil,
        navigationTitle: String,
        title: String,
        subtitle: String? = nil,
        submitTitle: String
    ) {
        self.initialSelection = initialSelection
        self.stepIndicator = stepIndicator
        self.navigationTitle = navigationTitle
        self.title = title
        self.subtitle = subtitle
        self.submitTitle = submitTitle
    }
}

public extension ArtistEditConfig {
    static func onboarding() -> ArtistEditConfig {
        ArtistEditConfig(
            stepIndicator: (current: 4, total: 4),
            navigationTitle: "회원가입",
            title: "선호하는 아티스트를\n3명 선택해 주세요",
            subtitle: "마이페이지에서 언제든 바꿀 수 있어요",
            submitTitle: "가입 완료"
        )
    }
    
    static func home() -> ArtistEditConfig {
        ArtistEditConfig(
            stepIndicator: (current: 2, total: 2),
            navigationTitle: "취향 선택",
            title: "좋아하는 아티스트를\n3명 선택해 주세요",
            subtitle: nil,
            submitTitle: "취향 선택 완료"
        )
    }
    
    static func edit(selectedArtists: [PreferredArtist]) -> ArtistEditConfig {
        ArtistEditConfig(
            initialSelection: selectedArtists,
            stepIndicator: nil,
            navigationTitle: "아티스트 변경",
            title: "선호하는 아티스트를\n3명 선택해 주세요",
            subtitle: nil,
            submitTitle: "변경하기"
        )
    }
}
