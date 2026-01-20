//
//  ConcertMerchandise.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertMerchandise: Hashable {
    public let imageURL: URL
    public let link: URL
    
    public init(imageURL: URL, link: URL) {
        self.imageURL = imageURL
        self.link = link
    }
}
