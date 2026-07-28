//
//  ConcertGenre.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum ConcertGenre: String, CaseIterable {
    case all = "ALL"
    case jpop = "JPOP"
    case rockMetal = "ROCK_METAL"
    case rapHiphop = "RAP_HIPHOP"
    case pop = "POP"
    case indie = "INDIE"
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
        case .pop:
            return "팝"
        case .indie:
            return "인디"
        case .all:
            return "전체"
        }
    }

    var genreEnglishText: String {
        switch self {
        case .jpop:
            return "J-POP"
        case .rockMetal:
            return "ROCK/METAL"
        case .rapHiphop:
            return "RAP/HIPHOP"
        case .pop:
            return "POP"
        case .indie:
            return "INDIE"
        case .all:
            return "전체"
        }
    }
}
