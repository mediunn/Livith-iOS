//
//  Artist.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct Artist: Codable, Equatable {
    public let id: Int
    public let name: String
    public let debutYear: String
    public let category: String
    public let imageURL: String?
    public let detail: String
    public let keywords: [String]
    public let instagramURL: String?

    public init(
        id: Int,
        name: String,
        debutYear: String,
        category: String,
        imageURL: String?,
        detail: String,
        keywords: [String],
        instagramURL: String?
    ) {
        self.id = id
        self.name = name
        self.debutYear = debutYear
        self.category = category
        self.imageURL = imageURL
        self.detail = detail
        self.keywords = keywords
        self.instagramURL = instagramURL
    }
}
