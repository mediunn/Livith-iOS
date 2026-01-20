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
    public let imageURL: URL?
    
    public init(id: Int, name: String, imageURL: URL?) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}
