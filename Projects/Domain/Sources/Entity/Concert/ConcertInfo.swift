//
//  ConcertInfo.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertInfo: Hashable {
    public let casting: String
    public let runtime: String
    public let ageLimit: String
    public let price: String
    
    public init(casting: String, runtime: String, ageLimit: String, price: String) {
        self.casting = casting
        self.runtime = runtime
        self.ageLimit = ageLimit
        self.price = price
    }
}
