//
//  CalendarHomeContentView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/17/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct CalendarHomeContentView: View {

    // MARK: - Properties

    @ObservedObject var store: HomeStore

    // MARK: - Body

    var body: some View {
        VStack {
            Spacer()
            Text(Constants.placeholderText)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.black50))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Constants

private extension CalendarHomeContentView {
    enum Constants {
        static let placeholderText = "준비 중"
    }
}
