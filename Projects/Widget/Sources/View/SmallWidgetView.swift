//
//  SmallWidgetView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WidgetKit
import LivithDesignSystem
import UIKit

struct SmallWidgetView: View {
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
                WidgetEmptyView(family: .systemSmall)
            }
        }
        .widgetURL(deepLinkURL)
        .containerBackground(Color.livithColor(.black100), for: .widget)
    }
}

// MARK: - Content View

private extension SmallWidgetView {
    var contentView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                posterImage
                    .padding(.trailing, 8)

                VStack(alignment: .trailing) {
                    Image.livithImage(.livithLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32)

                    if let formattedDDay = entry.formattedDDay {
                        Text(formattedDDay)
                            .notosans(.headSemibold)
                            .foregroundStyle(Color.livithColor(.black50))
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.bottom, 8)
            
            if let concertTitle = entry.concertTitle {
                Text(concertTitle)
                    .notosans(.body4Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            Spacer()
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
        .frame(width: 60, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview

#Preview("Empty") {
    SmallWidgetView(entry: .placeholder)
        .frame(width: 170, height: 170)
}

#Preview("With Data") {
    SmallWidgetView(entry: .preview)
        .frame(width: 170, height: 170)
}
