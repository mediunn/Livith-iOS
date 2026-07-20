//
//  CalendarDayScheduleFixture.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

#if DEBUG
import Foundation

enum CalendarDayScheduleFixture {
    static let dayTitle = "6월 20일 수요일"

    static let itemList: [CalendarDayScheduleItem] = [
        CalendarDayScheduleItem(
            id: "1",
            kind: .ticketing,
            title: "위켄드 내한공연 2026",
            subtitle: "NOL 티켓",
            time: .init(hour: 18, minute: 0),
            isCancelled: false
        ),
        CalendarDayScheduleItem(
            id: "2",
            kind: .performance,
            title: "위켄드 내한공연 2026인데 만약 내용이 길어지면 최대 두줄까지 표시합니다 두 줄을 넘기면 말줄임이 적용되는지 확인하는 긴 제목입니다",
            subtitle: "얘는 내용이 길어질 시 한 줄 까지만 표시합니다!! 상세 일정",
            time: .init(hour: 18, minute: 0),
            isCancelled: false
        ),
        CalendarDayScheduleItem(
            id: "3",
            kind: .ticketing,
            title: "위켄드 내한공연 2026",
            subtitle: "추후 발표",
            time: nil,
            isCancelled: false
        ),
        CalendarDayScheduleItem(
            id: "4",
            kind: .ticketing,
            title: "위켄드 내한공연 2026",
            subtitle: "잠실 실내체육관",
            time: .init(hour: 12, minute: 0),
            isCancelled: true
        )
    ]
}
#endif
