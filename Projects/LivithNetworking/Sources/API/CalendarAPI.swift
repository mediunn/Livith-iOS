//
//  CalendarAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 7/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum CalendarAPI {
    public static func fetchMonth(
        startDate: String,
        endDate: String,
        scheduleTypes: [String],
        concertType: String
    ) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "startDate", value: startDate),
            URLQueryItem(name: "endDate", value: endDate),
            URLQueryItem(name: "concertType", value: concertType)
        ]
        scheduleTypes.forEach { queryItems.append(URLQueryItem(name: "scheduleTypes", value: $0)) }

        return NetworkEndpoint(
            path: "/calendar",
            method: .get,
            task: .query(queryItems),
            authentication: concertType == "INTEREST" ? .required : .none
        )
    }

    public static func fetchDayEvents(
        date: String,
        scheduleTypes: [String],
        concertType: String
    ) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "concertType", value: concertType)
        ]
        scheduleTypes.forEach { queryItems.append(URLQueryItem(name: "scheduleTypes", value: $0)) }

        return NetworkEndpoint(
            path: "/calendar/events",
            method: .get,
            task: .query(queryItems),
            authentication: concertType == "INTEREST" ? .required : .none
        )
    }
}
