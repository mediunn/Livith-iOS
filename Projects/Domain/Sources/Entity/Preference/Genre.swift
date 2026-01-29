//
//  Genre.swift
//  Domain
//
//  Created by 김진웅 on 29/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Genre: Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let imageURL: URL
}

public extension Genre {
    var displayName: String {
        switch name {
        case "JPOP": return "J-POP"
        case "ROCK_METAL": return "락/메탈"
        case "RAP_HIPHOP": return "랩/힙합"
        case "CLASSIC_JAZZ": return "클래식/재즈"
        case "ACOUSTIC": return "어쿠스틱"
        case "ELECTRONIC": return "일렉트로닉"
        default: return name
        }
    }
}
