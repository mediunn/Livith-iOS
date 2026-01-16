//
//  WidgetEmptyView.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WidgetKit
import LivithDesignSystem

struct WidgetEmptyView: View {
    let family: WidgetFamily

    var body: some View {
        switch family {
        case .systemSmall:
            LivithEmptyView(text: "관심 콘서트\n설정하기")

        case .systemMedium:
            ZStack(alignment: .topTrailing) {
                LivithEmptyView(text: "관심 콘서트 설정하기")

                Image.livithImage(.livithLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .padding(12)
            }

        case .systemLarge:
            VStack {
                HStack {
                    Spacer()
                    Image.livithImage(.livithLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()

                LivithEmptyView(text: "관심 콘서트 설정하기")

                Spacer()
                Spacer()
            }

        default:
            LivithEmptyView(text: "관심 콘서트\n설정하기")
        }
    }
}

// MARK: - Preview

#Preview("Small") {
    WidgetEmptyView(family: .systemSmall)
        .frame(width: 170, height: 170)
}

#Preview("Medium") {
    WidgetEmptyView(family: .systemMedium)
        .frame(width: 360, height: 170)
}

#Preview("Large") {
    WidgetEmptyView(family: .systemLarge)
        .frame(width: 360, height: 376)
}
