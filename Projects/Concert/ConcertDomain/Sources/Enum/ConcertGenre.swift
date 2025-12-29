//
//  ConcertGenre.swift
//  ConcertDomain
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ConcertGenre: String, CaseIterable {
    case jpop = "JPOP"
    case rockMetal = "ROCK_METAL"
    case rapHiphop = "RAP_HIPHOP"
    case classicJazz = "CLASSIC_JAZZ"
    case acoustic = "ACOUSTIC"
    case electronic = "ELECTRONIC"
    case all = "ALL"
}

public extension ConcertGenre {
    var genreText: String {
        switch self {
        case .jpop:
            return "J-POP"
        case .rockMetal:
            return "락/메탈"
        case .rapHiphop:
            return "랩/힙합"
        case .classicJazz:
            return "클래식/재즈"
        case .acoustic:
            return "어쿠스틱"
        case .electronic:
            return "일렉트로닉"
        case .all:
            return "전체"
        }
    }
}
