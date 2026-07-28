//
//  ConcertMerchandise.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertMerchandise: Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let price: String?
    public let imageURL: URL?
    
    public init(id: Int, name: String, price: String?, imageURL: URL?) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURL = imageURL
    }
}
