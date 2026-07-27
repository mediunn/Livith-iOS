//
//  CalendarWebMonthPayloadMapper.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/24/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithFoundation

enum CalendarWebMonthPayloadMapper {

    private static let encoder = JSONEncoder()

    static func jsonString(from month: CalendarMonth) -> String? {
        let payload = month.dayList.map { day in
            Day(
                date: DateFormatterService.string(from: day.date, type: .dashDate),
                events: day.eventList.map { event in
                    Event(
                        id: event.concertID,
                        artist: event.artist,
                        type: event.type.rawValue
                    )
                }
            )
        }

        guard let data = try? encoder.encode(payload) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Payload

private extension CalendarWebMonthPayloadMapper {
    struct Day: Encodable {
        let date: String
        let events: [Event]
    }

    struct Event: Encodable {
        let id: Int
        let artist: String
        let type: String
    }
}
