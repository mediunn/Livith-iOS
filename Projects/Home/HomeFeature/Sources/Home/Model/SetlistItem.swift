//
//  SetlistItem.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

struct SetlistItem: Identifiable, Hashable {
    let id: String
    let posterURL: String
    let title: String
    let singer: String
    let location: String
    let date: String
}

extension SetlistItem {
    static let sample = SetlistItem(
        id: "1",
        posterURL: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg",
        title: "MAD HOPE Asia Tour 2025 dsalkfsjsajfd",
        singer: "Hosino Gen",
        location: "Japan, Dokyo",
        date: "2022년 3월 25일"
    )
}
