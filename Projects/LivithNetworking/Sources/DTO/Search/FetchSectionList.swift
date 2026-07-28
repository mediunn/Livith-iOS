//
//  FetchSectionList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

// MARK: - 9. 탐색 화면 섹션 목록 조회

import Foundation

public extension DTO.Response {
    typealias FetchSectionList = [Section]

    struct Section: Decodable {
        public typealias Concert = DTO.Response.FetchFilterSearchResult.FilteredConcert

        public let id: Int
        public let sectionTitle: String
        public let concerts: [Concert]
    }
}
