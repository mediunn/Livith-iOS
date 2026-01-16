//
//  MediumWidgetView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WidgetKit
import LivithDesignSystem
import UIKit

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
                HStack {
                    Spacer()
                    Image.livithImage(.livithLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                }

                Spacer()

                infoSection

                Spacer()

                moreInfoButton
            }
        }
        .padding(12)
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
        .frame(width: 100, height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    var infoSection: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                if let formattedDDay = entry.formattedDDay {
                    Text(formattedDDay)
                        .notosans(.headSemibold)
                        .foregroundStyle(Color.livithColor(.white100))
                }
                
                if let title = entry.concertTitle {
                    Text(title)
                        .notosans(.caption1Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                        .lineLimit(2)
                }

                if let artistName = entry.artistName {
                    Text(artistName)
                        .notosans(.caption2Regular)
                        .foregroundStyle(Color.livithColor(.black30))
                        .lineLimit(1)
                }
            }

            Spacer()

        }
    }

    var moreInfoButton: some View {
        HStack(spacing: 4) {
            Text("더 많은 정보 확인하기")
                .notosans(.caption2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
            Image.livithIcon(.rightLineSmall)
                .foregroundStyle(Color.livithColor(.white100))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.livithColor(.black100))
        .clipShape(RoundedRectangle(cornerRadius: 6))
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
