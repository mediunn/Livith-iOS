//
//  FetchBannerList.swift
//  network
//
//  Created by Youjin Lee on 10/14/25.
//  Copyright © 2025 Livith. All rights reserved.
//

// MARK: - 10. 배너 조회

import Foundation

public extension DTO.Response {
    typealias FetchBannerList = [Banner]

    struct Banner: Decodable {
        public let id: Int
        public let title: String
        public let category: String
        public let imageURL: String
        public let content: String
        public let linkURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case category
            case imageURL = "imgUrl"
            case content
            case linkURL = "linkUrl"
        }
    }
}
