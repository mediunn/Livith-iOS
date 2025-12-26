//
//  ConcertSection.swift
//  HomeDomain
//
//  Created by 김진웅 on 12/26/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ConcertSection: Hashable, Identifiable {
    public let id: Int
    public let title: String
    public let concertList: [Concert]
    
    public init(id: Int, title: String, concerts: [Concert]) {
        self.id = id
        self.title = title
        self.concertList = concerts
    }
}
