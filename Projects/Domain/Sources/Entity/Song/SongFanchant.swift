//
//  SongFanchant.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct SongFanchant: Identifiable, Hashable {
    public let id: Int
    public let setlistID: Int
    public let songID: Int
    public let fanchant: [String]
    public let fanchantPoint: String?

    public init(
        id: Int,
        setlistID: Int,
        songID: Int,
        fanchant: [String],
        fanchantPoint: String?
    ) {
        self.id = id
        self.setlistID = setlistID
        self.songID = songID
        self.fanchant = fanchant
        self.fanchantPoint = fanchantPoint
    }
}
