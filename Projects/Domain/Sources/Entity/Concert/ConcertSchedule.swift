//
//  ConcertSchedule.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public struct ConcertSchedule: Hashable {
    public let date: Date
    public let link: URL
    
    public init(date: Date, link: URL) {
        self.date = date
        self.link = link
    }
}
