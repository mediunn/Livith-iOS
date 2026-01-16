//
//  WidgetDataService.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import LivithFoundation
import LivithNetwork
import Persistence

struct WidgetDataService {
    private static let appGroupID = "group.com.youz2me.livith"

    private let storage: UserDefaultsStorage
    private let imageStorage: WidgetImageStorage
    private let decoder: JSONDecoder

    init(
        storage: UserDefaultsStorage = UserDefaultsStorage(
            defaults: UserDefaults(suiteName: appGroupID) ?? .standard
        ),
        imageStorage: WidgetImageStorage = WidgetImageStorage(appGroupID: appGroupID),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.storage = storage
        self.imageStorage = imageStorage
        self.decoder = decoder
    }

    func fetchInterestConcert() -> LivithWidgetEntry {
        guard let concert: DTO.Response.UpdateUserInterestConcert = try? storage.fetch(for: .interestConcert) else {
            return .placeholder
        }

        let dDay = calculateDDay(from: concert.startDate)
        let imageData = imageStorage.load(forKey: Keys.interestConcertPoster)

        return LivithWidgetEntry(
            date: Date(),
            concertID: concert.id,
            posterImageData: imageData,
            artistName: concert.artist,
            concertTitle: concert.title,
            dDay: dDay,
            schedules: []
        )
    }

    func fetchInterestConcertWithSchedules() async -> LivithWidgetEntry {
        guard let concert: DTO.Response.UpdateUserInterestConcert = try? storage.fetch(for: .interestConcert) else {
            return .placeholder
        }

        let dDay = calculateDDay(from: concert.startDate)
        let imageData = imageStorage.load(forKey: Keys.interestConcertPoster)
        let schedules = await fetchSchedules(concertID: concert.id)

        return LivithWidgetEntry(
            date: Date(),
            concertID: concert.id,
            posterImageData: imageData,
            artistName: concert.artist,
            concertTitle: concert.title,
            dDay: dDay,
            schedules: schedules
        )
    }
}

// MARK: - Private Helpers

private extension WidgetDataService {
    func calculateDDay(from dateString: String) -> Int {
        guard let targetDate = DateFormatterService.date(from: dateString, type: .dashDate) else {
            return 0
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)

        let components = calendar.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }

    func fetchSchedules(concertID: Int) async -> [ScheduleItem] {
        let endpoint = ConcertEndpoint.fetchConcertSchedule(concertID: concertID)
        guard let path = endpoint.path else { return [] }

        let url = Bundle.baseURL.appendingPathComponent(path)

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try decoder.decode(ScheduleAPIResponse.self, from: data)
            return response.data.prefix(3).map { schedule in
                let scheduleDateString = String(schedule.scheduledAt.prefix(10))
                return ScheduleItem(
                    id: schedule.id,
                    category: schedule.category,
                    scheduledAt: schedule.scheduledAt,
                    dDay: calculateDDay(from: scheduleDateString)
                )
            }
        } catch {
            return []
        }
    }
}

// MARK: - Keys

private extension WidgetDataService {
    enum Keys {
        static let interestConcertPoster = "interestConcertPoster"
    }
}

// MARK: - Schedule API Response

private struct ScheduleAPIResponse: Decodable {
    let data: [DTO.Response.ConcertSchedule]
}
