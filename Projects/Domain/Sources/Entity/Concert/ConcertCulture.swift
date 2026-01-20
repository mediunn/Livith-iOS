//
//  ConcertCulture.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertCulture: Hashable {
    public let title: String
    public let content: String
    
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}
