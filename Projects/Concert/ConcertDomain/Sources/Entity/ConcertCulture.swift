//
//  ConcertCulture.swift
//  Concert
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public struct ConcertCulture: Hashable, Identifiable {
    public let id: Int
    public let concertID: Int
    public let title: String
    public let content: String
}
