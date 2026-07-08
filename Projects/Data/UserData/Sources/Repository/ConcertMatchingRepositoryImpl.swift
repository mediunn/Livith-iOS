//
//  ConcertMatchingRepositoryImpl.swift
//  UserData
//
//  Created by youz2me on 7/8/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain

public struct ConcertMatchingRepositoryImpl: ConcertMatchingRepository {
    public init() {}

    public func fetchMatchedConcertList(sourceURL: URL) async throws(ConcertMatchingError) -> [Concert] {
        // TODO: 인스타그램 파싱·매칭 서버 API 확정 시 네트워크 연동으로 교체 (LIVD-427 후속)
        throw ConcertMatchingError.matchFailed
    }
}
