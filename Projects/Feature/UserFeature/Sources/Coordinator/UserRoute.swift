//
//  UserRoute.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

enum UserRoute: Hashable {
    case user
    case setting
    case noticeSetting
    case nicknameUpdate
    case deleteUser
    case genreUpdate(selectedGenreList: [PreferredGenre])
    case artistUpdate(selectedArtistList: [PreferredArtist])
}
