//
//  SignupBuilder.swift
//  LoginFeature
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

struct SignupBuilder: Hashable {
    let tempUser: TempUser
    let isMarketingAgreed: Bool
    let nickname: String
    let preferredGenreList: [PreferredGenre]
    
    private init(
        tempUser: TempUser,
        isMarketingAgreed: Bool,
        nickname: String,
        preferredGenreList: [PreferredGenre]
    ) {
        self.tempUser = tempUser
        self.isMarketingAgreed = isMarketingAgreed
        self.nickname = nickname
        self.preferredGenreList = preferredGenreList
    }
    
    // MARK: - Builder Methods
    
    /// Step 1: 약관 동의 후 시작
    static func start(tempUser: TempUser, isMarketingAgreed: Bool) -> SignupBuilder {
        SignupBuilder(
            tempUser: tempUser,
            isMarketingAgreed: isMarketingAgreed,
            nickname: "",
            preferredGenreList: []
        )
    }
    
    /// Step 2: 닉네임 설정
    func withNickname(_ nickname: String) -> SignupBuilder {
        SignupBuilder(
            tempUser: tempUser,
            isMarketingAgreed: isMarketingAgreed,
            nickname: nickname,
            preferredGenreList: preferredGenreList
        )
    }
    
    /// Step 3: 선호 장르 설정
    func withPreferredGenreList(_ genres: [PreferredGenre]) -> SignupBuilder {
        SignupBuilder(
            tempUser: tempUser,
            isMarketingAgreed: isMarketingAgreed,
            nickname: nickname,
            preferredGenreList: genres
        )
    }
    
    /// Step 4: 최종 빌드 - 회원가입 요청 데이터 생성
    func build(preferredArtistList: [PreferredArtist]) throws -> SignupInfo {
        let validatedNickname = try Nickname(nickname)
        
        return try SignupInfo(
            provider: tempUser.provider,
            providerID: tempUser.providerID,
            email: tempUser.email,
            nickname: validatedNickname,
            isMarketingAgreed: isMarketingAgreed,
            preferredGenreIDList: preferredGenreList.map { $0.id },
            preferredArtistIDList: preferredArtistList.map { $0.id }
        )
    }
}

