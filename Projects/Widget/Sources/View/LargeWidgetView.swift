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
        VStack(spacing: 0) {
            concertInfoSection
                .padding(16)
                .padding(.top, 16)
                .background(
                    Color.livithColor(.black90)
                        .padding(-16)
                )

            VStack {
                scheduleSection
                Spacer()
            }
            .padding(16)
            .padding(.top, 16)
        }
    }

    var concertInfoSection: some View {
        HStack(alignment: .top, spacing: 16) {
            posterImage

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Image.livithImage(.livithLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    if let formattedDDay = entry.formattedDDay {
                        Text(formattedDDay)
                            .notosans(.headSemibold)
                            .foregroundStyle(Color.livithColor(.black50))
                    }

                    if let title = entry.concertTitle {
                        Text(title)
                            .notosans(.body4Semibold)
                            .foregroundStyle(Color.livithColor(.white100))
                    }

                    if let artistName = entry.artistName {
                        Text(artistName)
                            .notosans(.caption2Regular)
                            .foregroundStyle(Color.livithColor(.black30))
                    }
                }
            }
            .frame(height: 147)
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
        .frame(width: 104, height: 147)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var scheduleSection: some View {
        VStack(spacing: .zero) {
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
