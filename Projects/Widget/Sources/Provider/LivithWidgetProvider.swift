//
//  LivithWidgetProvider.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import WidgetKit

struct LivithWidgetProvider: TimelineProvider {
    private let dataService = WidgetDataService()

    func placeholder(in context: Context) -> LivithWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (LivithWidgetEntry) -> Void) {
        let entry = dataService.fetchInterestConcert()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LivithWidgetEntry>) -> Void) {
        let entry = dataService.fetchInterestConcert()

        // 다음 자정에 갱신 (D-day 업데이트를 위해)
        let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }
}

// MARK: - Large Widget Provider

struct LargeWidgetProvider: TimelineProvider {
    private let dataService = WidgetDataService()

    func placeholder(in context: Context) -> LivithWidgetEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (LivithWidgetEntry) -> Void) {
        Task {
            let entry = await dataService.fetchInterestConcertWithSchedules()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LivithWidgetEntry>) -> Void) {
        Task {
            let entry = await dataService.fetchInterestConcertWithSchedules()

            // 다음 자정에 갱신
            let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
            let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
            completion(timeline)
        }
    }
}
