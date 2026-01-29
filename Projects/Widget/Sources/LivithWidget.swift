//
//  LivithWidget.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - Small & Medium Widget

struct LivithWidget: Widget {
    let kind: String = "LivithWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LivithWidgetProvider()) { entry in
            LivithWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("관심 콘서트")
        .description("관심 콘서트의 D-day를 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Large Widget

struct LivithLargeWidget: Widget {
    let kind: String = "LivithLargeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LargeWidgetProvider()) { entry in
            LargeWidgetView(entry: entry)
        }
        .configurationDisplayName("관심 콘서트 (일정 포함)")
        .description("관심 콘서트의 D-day와 일정을 확인하세요")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Entry View

struct LivithWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: LivithWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
