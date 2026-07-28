//
//  Artist.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Artist: Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let debutYear: String
    public let category: String
    public let imageURL: URL?
    public let detail: String
    public let keywords: [String]
    public let instagramURL: URL?
    public let twitterURL: URL?

    public init(
        id: Int,
        name: String,
        debutYear: String,
        category: String,
        imageURL: URL?,
        detail: String,
        keywords: [String],
        instagramURL: URL?,
        twitterURL: URL?
    ) {
        self.id = id
        self.name = name
        self.debutYear = debutYear
        self.category = category
        self.imageURL = imageURL
        self.detail = detail
        self.keywords = keywords
        self.instagramURL = instagramURL
        self.twitterURL = twitterURL
    }
}
