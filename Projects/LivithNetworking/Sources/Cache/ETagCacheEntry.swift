//
//  ETagCacheEntry.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/13/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct ETagCacheEntry: Sendable {
    let etag: String
    let data: Data
    let statusCode: Int
}
