//
//  Signup.swift
//  Domain
//
//  Created by 김진웅 on 2/5/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Signup: Hashable {
    
    // MARK: - Constants
    
    private static let maxGenreCount = 3
    private static let maxArtistCount = 3
    
    // MARK: - Properties
    
    public let provider: SocialLoginProvider
    public let providerID: String
    public let email: String?
    public let nickname: Nickname
    public let isMarketingAgreed: Bool
    public let preferredGenreIDList: [Int]
    public let preferredArtistIDList: [Int]
    
    // MARK: - Initializer
    
    public init(
        provider: SocialLoginProvider,
        providerID: String,
        email: String?,
        nickname: Nickname,
        isMarketingAgreed: Bool,
        preferredGenreIDList: [Int],
        preferredArtistIDList: [Int]
    ) throws {
        guard !preferredGenreIDList.isEmpty else {
            throw AuthError.emptyGenreList
        }
        guard preferredGenreIDList.count <= Self.maxGenreCount else {
            throw AuthError.genreExceedsLimit
        }
        
        guard preferredArtistIDList.count <= Self.maxArtistCount else {
            throw AuthError.artistExceedsLimit
        }
        
        self.provider = provider
        self.providerID = providerID
        self.email = email
        self.nickname = nickname
        self.isMarketingAgreed = isMarketingAgreed
        self.preferredGenreIDList = preferredGenreIDList
        self.preferredArtistIDList = preferredArtistIDList
    }
}

