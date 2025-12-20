//
//  Sections.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 9. 탐색 화면 섹션 목록 조회

import Foundation

public extension DTO.Response {
    typealias Sections = [Section]

    struct Section: Decodable {
        public let id: Int
        public let sectionTitle: String
        public let concerts: [Concert]
    }
}

public extension DTO.Response.Section {
    struct Concert: Decodable {
        
        // TODO: Section에서 사용되는 콘서트 DTO 구현하기
        
    }
}
