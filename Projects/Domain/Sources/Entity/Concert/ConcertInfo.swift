//
//  ConcertInfo.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertInfo: Identifiable, Hashable {
    public let id: Int
    public let imageURL: String
    public let title: String
    public let description: String
    
    public init(id: Int, imageURL: String, title: String, description: String) {
        self.id = id
        self.imageURL = imageURL
        self.title = title
        self.description = description
    }
}
