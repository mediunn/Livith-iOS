//
//  FetchBannerList.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
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
            case id, title, category
            case imageURL = "imgUrl"
            case content
            case linkURL = "linkUrl"
        }
    }
}
