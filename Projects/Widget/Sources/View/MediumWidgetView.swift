//
//  MediumWidgetView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit
import SwiftUI
import WidgetKit

import LivithDesignSystem

struct MediumWidgetView: View {
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
                WidgetEmptyView(family: .systemMedium)
            }
        }
        .widgetURL(deepLinkURL)
        .containerBackground(Color.livithColor(.black100), for: .widget)
    }
}

// MARK: - Content View

private extension MediumWidgetView {
    var contentView: some View {
        HStack(spacing: 12) {
            posterImage

            VStack(alignment: .leading, spacing: 0) {
                if let formattedDDay = entry.formattedDDay {
                    Text("| \(formattedDDay)")
                        .pretendard(.semiBold, 26)
                        .foregroundStyle(Color.livithColor(.white100))
                        .padding(.bottom, 3)
                }

                if let concertTitle = entry.concertTitle {
                    Text(concertTitle)
                        .pretendard(.semiBold, 14)
                        .foregroundStyle(Color.livithColor(.white100))
                        .lineLimit(2)
                        .padding(.bottom, 6)
                }

                if let dateRange = entry.concertDateRange {
                    HStack(spacing: 6) {
                        Image.livithIcon(.calendarLine)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
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
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.livithColor(.black30))
                        Text(venue)
                            .pretendard(.regular, 12)
                            .foregroundStyle(Color.livithColor(.black30))
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
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
        .frame(width: 81, height: 123)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview("Empty") {
    MediumWidgetView(entry: .placeholder)
        .frame(width: 360, height: 170)
}

#Preview("With Data") {
    MediumWidgetView(entry: .preview)
        .frame(width: 360, height: 170)
}
