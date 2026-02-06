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
        VStack(spacing: 10) {
            Image.livithIcon(.plusFillBig)
                .resizable()
                .frame(width: 40, height: 40)

            Text(emptyText)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .multilineTextAlignment(.center)
        }
    }

    private var emptyText: String {
        switch family {
        case .systemSmall:
            return "관심 콘서트 추가"
        default:
            return "관심 콘서트를 추가하면\n공연 소식을 한눈에 볼 수 있어요"
        }
    }
}

// MARK: - Preview

#Preview("Small") {
    WidgetEmptyView(family: .systemSmall)
        .frame(width: 170, height: 170)
        .background(Color.livithColor(.black100))
}

#Preview("Medium") {
    WidgetEmptyView(family: .systemMedium)
        .frame(width: 360, height: 170)
        .background(Color.livithColor(.black100))
}

#Preview("Large") {
    WidgetEmptyView(family: .systemLarge)
        .frame(width: 360, height: 376)
        .background(Color.livithColor(.black100))
}
