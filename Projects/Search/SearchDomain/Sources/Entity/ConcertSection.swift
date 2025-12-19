//
//  ConcertSection.swift
//  SearchDomain
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ConcertSection: Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let concerts: [ConcertEntity]
    
    public init(id: Int, title: String, concerts: [ConcertEntity]) {
        self.id = id
        self.title = title
        self.concerts = concerts
    }
}
