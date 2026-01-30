//
//  LargeWidgetView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit
import SwiftUI
import WidgetKit

import LivithDesignSystem
import LivithFoundation

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
        VStack(spacing: 0) {
            concertInfoSection

            Divider()
                .background(Color.livithColor(.black80))

            scheduleSection
                .padding(.top, 12)

            Spacer(minLength: 0)
        }
    }

    var concertInfoSection: some View {
        HStack(spacing: 12) {
            posterImage

            VStack(alignment: .leading, spacing: 0) {
                if let formattedDDay = entry.formattedDDay {
                    Text("| \(formattedDDay)")
                        .pretendard(.semiBold, 26)
                        .foregroundStyle(Color.livithColor(.white100))
                }

                Spacer()

                if let concertTitle = entry.concertTitle {
                    Text(concertTitle)
                        .pretendard(.semiBold, 14)
                        .foregroundStyle(Color.livithColor(.white100))
                        .lineLimit(2)
                }

                Spacer()
                    .frame(height: 8)

                if let dateRange = entry.concertDateRange {
                    HStack(spacing: 6) {
                        Image.livithIcon(.calendarLine)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.livithColor(.black30))
                        Text(dateRange)
                            .pretendard(.regular, 12)
                            .foregroundStyle(Color.livithColor(.black30))
                    }
                }

                if let venue = entry.venue {
                    HStack(spacing: 6) {
                        Image.livithIcon(.locationLine)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.livithColor(.black30))
                        Text(venue)
                            .pretendard(.regular, 12)
                            .foregroundStyle(Color.livithColor(.black30))
                            .lineLimit(1)
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 12)
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
        .frame(width: 110, height: 155)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var scheduleSection: some View {
        VStack(spacing: 0) {
            ForEach(entry.schedules) { schedule in
                LivithScheduleItem(
                    daysLeft: schedule.dDay,
                    title: schedule.category,
                    dateTime: formatScheduleDate(schedule.scheduledAt),
                    isActive: schedule.dDay >= 0
                )
                .frame(height: 48)
            }
        }
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
