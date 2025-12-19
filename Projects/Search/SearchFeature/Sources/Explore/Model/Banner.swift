//
//  Banner.swift
//  SearchFeature
//
//  Created by 김진웅 on 12/19/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

struct Banner: Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let imageURL: URL?
}

extension Banner {
    static var mocks: [Self] {
        return [
            Banner(
                id: 1,
                title: "라이빗 서비스 오픈!",
                description: "새로운 라이빗 서비스가 정식 오픈되었습니다. 많은 이용 부탁드립니다.",
                category: "공지",
                imageURL: nil
            ),
            Banner(
                id: 2,
                title: "겨울 이벤트 시작!",
                description: "겨울 시즌을 맞아 특별 이벤트를 진행합니다. 참여해보세요!",
                category: "이벤트",
                imageURL: URL(string: "https://fastly.picsum.photos/id/643/365/365.jpg?hmac=ltH7rZPrQvX1Lwm0WY-aAWvyxAsOrqwmWilmxnn_GJY")
            ),
            Banner(
                id: 3,
                title: "신규 기능 업데이트",
                description: "더 나은 사용자 경험을 위해 새로운 기능을 추가했습니다.",
                category: "업데이트",
                imageURL: URL(string: "https://fastly.picsum.photos/id/643/365/365.jpg?hmac=ltH7rZPrQvX1Lwm0WY-aAWvyxAsOrqwmWilmxnn_GJY")
            ),
            Banner(
                id: 4,
                title: "커뮤니티 참여 이벤트",
                description: "커뮤니티에 참여하여 다양한 혜택을 받아보세요.",
                category: "커뮤니티",
                imageURL: URL(string: "https://fastly.picsum.photos/id/643/365/365.jpg?hmac=ltH7rZPrQvX1Lwm0WY-aAWvyxAsOrqwmWilmxnn_GJY")
            ),
            Banner(
                id: 5,
                title: "연말 감사 프로모션",
                description: "연말을 맞아 감사하는 마음으로 프로모션을 진행합니다.",
                category: "프로모션",
                imageURL: URL(string: "https://fastly.picsum.photos/id/643/365/365.jpg?hmac=ltH7rZPrQvX1Lwm0WY-aAWvyxAsOrqwmWilmxnn_GJY")
            )
        ]
    }
}

