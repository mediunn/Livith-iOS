//
//  ConcertMatchingRepository.swift
//  Domain
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public protocol ConcertMatchingRepository {
    func fetchMatchedConcertList(sourceURL: URL) async throws(ConcertMatchingError) -> [Concert]
}
