//
//  ConcertCulture.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertCulture: Hashable, Identifiable {
    public let id: Int
    public let concertID: Int
    public let title: String
    public let content: String
    
    public init(id: Int, concertID: Int, title: String, content: String) {
        self.id = id
        self.concertID = concertID
        self.title = title
        self.content = content
    }
}
