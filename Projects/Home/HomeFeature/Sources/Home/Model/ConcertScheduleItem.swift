//
//  ConcertScheduleItem.swift
//  HomeFeature
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

typealias ConcertScheduleList = [ConcertScheduleItem]

struct ConcertScheduleItem: Hashable, Identifiable {
    let id: Int
    let date: Date
    let title: String
}

extension ConcertScheduleList {
    static func mock() -> ConcertScheduleList {
        let calendar = Calendar.current
        let today = Date()
        return [
            .init(id: 1, date: calendar.date(byAdding: .day, value: 10, to: today)!, title: "1일차 콘서트"),
            .init(id: 2, date: calendar.date(byAdding: .day, value: 11, to: today)!, title: "2일차 콘서트"),
            .init(id: 4, date: today, title: "오늘의 이벤트"),
            .init(id: 3, date: calendar.date(byAdding: .day, value: -5, to: today)!, title: "티켓팅 오픈")
        ].reversed()
    }
}
