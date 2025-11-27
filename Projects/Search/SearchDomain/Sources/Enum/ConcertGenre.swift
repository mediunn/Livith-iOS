//
//  ConcertGenre.swift
//  search
//
//  Created by Youjin Lee on 10/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public enum ConcertGenre: String, CaseIterable {
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
