//
//  ConcertMerchandise.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ConcertMerchandise: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let price: String?
    public let imageURL: String?

    public init(
        id: Int,
        name: String,
        price: String?,
        imageURL: String?
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURL = imageURL
    }
}
