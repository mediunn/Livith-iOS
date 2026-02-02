//
//  PreferredArtist.swift
//  Domain
//
//  Created by 김진웅 on 2/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct PreferredArtist: Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let genreID: Int
    public let imageURL: URL?

    public init(
        id: Int,
        name: String,
        genreID: Int,
        imageURL: URL?
    ) {
        self.id = id
        self.name = name
        self.genreID = genreID
        self.imageURL = imageURL
    }
}
