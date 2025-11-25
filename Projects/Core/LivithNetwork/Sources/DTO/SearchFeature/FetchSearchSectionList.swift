//
//  FetchSearchSectionList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 9. 탐색 화면 섹션 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchSearchSectionList = [SearchSection]

    struct SearchSection: Decodable {
        public let id: Int
        public let sectionTitle: String
        public let concerts: [Concert]
    }
}
