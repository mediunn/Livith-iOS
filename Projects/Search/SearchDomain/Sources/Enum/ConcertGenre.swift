//
//  ConcertGenre.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ConcertGenre: String {
    case jpop
    case rockMetal
    case rapHiphop
    case classicJazz
    case acoustic
    case electronic
    case all
}

public extension ConcertGenre {
    var rawValue: String {
        switch self {
        case .jpop:
            return "JPOP"
        case .rockMetal:
            return "ROCK_METAL"
        case .rapHiphop:
            return "RAP_HIPHOP"
        case .classicJazz:
            return "CLASSIC_JAZZ"
        case .acoustic:
            return "ACOUSTIC"
        case .electronic:
            return "ELECTRONIC"
        case .all:
            return "ALL"
        }
    }
}
