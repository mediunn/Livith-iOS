//
//  LargeWidgetView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WidgetKit
import LivithDesignSystem
import LivithFoundation
import UIKit

struct LargeWidgetView: View {
    let entry: LivithWidgetEntry

    private var deepLinkURL: URL {
        if let concertID = entry.concertID {
            return URL(string: "livith://concert/\(concertID)")!
        }
        return URL(string: "livith://home")!
    }

    var body: some View {
        Group {
            if entry.hasData {
                contentView
            } else {
                WidgetEmptyView(family: .systemLarge)
            }
        }
        .widgetURL(deepLinkURL)
        .containerBackground(Color.livithColor(.black100), for: .widget)
    }
}

// MARK: - Content View

private extension LargeWidgetView {
    var contentView: some View {
        VStack(spacing: 16) {
            concertInfoSection
            scheduleSection
        }
        .padding(16)
    }

    var concertInfoSection: some View {
        HStack(alignment: .top, spacing: 12) {
            posterImage

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Spacer()
                    Image.livithImage(.livithLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                }

                if let formattedDDay = entry.formattedDDay {
                    Text(formattedDDay)
                        .notosans(.headSemibold)
                        .foregroundStyle(Color.livithColor(.white100))
                }

                if let title = entry.concertTitle {
                    Text(title)
                        .notosans(.body4Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                        .lineLimit(2)
                }

                Spacer()
            }
        }
    }

    var posterImage: some View {
        Group {
            if let imageData = entry.posterImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.livithColor(.black90)
            }
        }
        .frame(width: 61, height: 74)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var scheduleSection: some View {
        VStack(spacing: 8) {
            ForEach(entry.schedules) { schedule in
                scheduleRow(schedule)
            }
        }
    }

    func scheduleRow(_ schedule: ScheduleItem) -> some View {
        HStack(spacing: 12) {
            dDayChip(schedule)

            Text(schedule.category)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)

            Spacer()

            Text(formatScheduleDate(schedule.scheduledAt))
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
        }
    }

    func dDayChip(_ schedule: ScheduleItem) -> some View {
        Text(schedule.formattedDDay)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black100))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.livithColor(.yellow60))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    func formatScheduleDate(_ dateString: String) -> String {
        guard let date = DateFormatterService.date(from: dateString, type: .iso8601) else {
            return dateString
        }
        return DateFormatterService.string(from: date, type: .koreanDateTime)
    }
}

// MARK: - Preview

#Preview("Empty") {
    LargeWidgetView(entry: .placeholder)
        .frame(width: 360, height: 376)
}

#Preview("With Data") {
    LargeWidgetView(entry: .preview)
        .frame(width: 360, height: 376)
}
