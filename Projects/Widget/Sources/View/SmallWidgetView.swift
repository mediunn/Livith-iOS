//
//  SmallWidgetView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit
import SwiftUI
import WidgetKit

import LivithDesignSystem

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
        .containerBackground(for: .widget) {
            if entry.hasData {
                ZStack {
                    backgroundImage
                    LinearGradient(
                        colors: [.black, .black.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                Color.livithColor(.black100)
            }
        }
    }
}

// MARK: - Content View

private extension SmallWidgetView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let formattedDDay = entry.formattedDDay {
                Text("| \(formattedDDay)")
                    .pretendard(.semiBold, 26)
                    .foregroundStyle(Color.livithColor(.white100))
            }

            Spacer()

            if let concertTitle = entry.concertTitle {
                Text(concertTitle)
                    .pretendard(.semiBold, 12)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(2)
            }

            if let concertDate = entry.concertDate {
                Text(concertDate)
                    .pretendard(.regular, 12)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var backgroundImage: some View {
        Group {
            if let imageData = entry.posterImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
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
