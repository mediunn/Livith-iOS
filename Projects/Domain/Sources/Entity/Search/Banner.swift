//
//  Banner.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct Banner: Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String
    public let category: String
    public let imageURL: URL?
    public let linkURL: URL?
    
    public init(id: Int, title: String, description: String, category: String, imageURL: URL?, linkURL: URL? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.imageURL = imageURL
        self.linkURL = linkURL
    }
}
