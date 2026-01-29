//
//  WidgetDataService.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import os

import Domain
import LivithFoundation
import LivithNetwork
import Persistence

struct WidgetDataService {
    private static let appGroupID = "group.com.youz2me.livith"
    private static let logger = Logger(subsystem: "com.youz2me.livith.widget", category: "WidgetDataService")

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

        let defaults = UserDefaults(suiteName: Self.appGroupID)
        Self.logger.debug("[Init] App Group UserDefaults: \(defaults != nil ? "성공" : "nil → .standard 폴백")")
    }

    func fetchInterestConcert() -> LivithWidgetEntry {
        do {
            let concert: Concert = try storage.fetch(for: .interestConcert)
            Self.logger.debug("[Fetch] Concert 디코딩 성공: \(concert.title, privacy: .public) id=\(concert.id, privacy: .public)")
            Self.logger.debug("[Fetch] startDate epoch: \(Int(concert.startDate.timeIntervalSince1970), privacy: .public)")

            let dDay = calculateDDay(from: concert.startDate)
            let imageData = imageStorage.load(forKey: Keys.interestConcertPoster)
            Self.logger.debug("[Fetch] D-Day: \(dDay), 이미지: \(imageData != nil ? "\(imageData!.count) bytes" : "nil")")

            return LivithWidgetEntry(
                date: Date(),
                concertID: concert.id,
                posterImageData: imageData,
                artistName: concert.artist,
                concertTitle: concert.title,
                dDay: dDay,
                startDate: concert.startDate,
                schedules: []
            )
        } catch {
            Self.logger.error("[Fetch] Concert 디코딩 실패: \(error.localizedDescription)")
            return .placeholder
        }
    }

    func fetchInterestConcertWithSchedules() async -> LivithWidgetEntry {
        do {
            let concert: Concert = try storage.fetch(for: .interestConcert)
            Self.logger.debug("[FetchLarge] Concert 디코딩 성공: \(concert.title, privacy: .public) startDate: \(concert.startDate.description, privacy: .public)")

            let dDay = calculateDDay(from: concert.startDate)
            let imageData = imageStorage.load(forKey: Keys.interestConcertPoster)
            let schedules = await fetchSchedules(concertID: concert.id)
            Self.logger.debug("[FetchLarge] 스케줄 \(schedules.count)개 로드")

            return LivithWidgetEntry(
                date: Date(),
                concertID: concert.id,
                posterImageData: imageData,
                artistName: concert.artist,
                concertTitle: concert.title,
                dDay: dDay,
                startDate: concert.startDate,
                schedules: schedules
            )
        } catch {
            Self.logger.error("[FetchLarge] Concert 디코딩 실패: \(error.localizedDescription)")
            return .placeholder
        }
    }
}

// MARK: - Private Helpers

private extension WidgetDataService {
    func calculateDDay(from date: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }

    func calculateDDay(from dateString: String) -> Int {
        guard let targetDate = DateFormatterService.date(from: dateString, type: .dashDate) else {
            return 0
        }
        return calculateDDay(from: targetDate)
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
