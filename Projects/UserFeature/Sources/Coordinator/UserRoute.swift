//
//  UserRoute.swift
//  UserFeature
//
//  Created by Youjin Lee on 1/28/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Coordinator
import Domain

enum UserRoute: Route {
    case user
    case setting
    case noticeSetting
    case nicknameUpdate
    case deleteUser
    case genreUpdate(selectedGenreList: [PreferredGenre])
    case artistUpdate(selectedArtistList: [PreferredArtist])
    
    static func == (lhs: UserRoute, rhs: UserRoute) -> Bool {
        switch (lhs, rhs) {
        case (.user, .user):
            return true
        case (.setting, .setting):
            return true
        case (.noticeSetting, .noticeSetting):
            return true
        case (.nicknameUpdate, .nicknameUpdate):
            return true
        case (.deleteUser, .deleteUser):
            return true
        case let (.genreUpdate(lhsGenres), .genreUpdate(rhsGenres)):
            return lhsGenres == rhsGenres
        case let (.artistUpdate(lhsArtists), .artistUpdate(rhsArtists)):
            return lhsArtists == rhsArtists
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .user:
            hasher.combine("user")
        case .setting:
            hasher.combine("setting")
        case .noticeSetting:
            hasher.combine("noticeSetting")
        case .nicknameUpdate:
            hasher.combine("nicknameUpdate")
        case .deleteUser:
            hasher.combine("deleteUser")
        case let .genreUpdate(selectedGenreList):
            hasher.combine("genreUpdate")
            hasher.combine(selectedGenreList)
        case let .artistUpdate(selectedArtistList):
            hasher.combine("artistUpdate")
            hasher.combine(selectedArtistList)
        }
    }
}
