//
//  ConcertSegmentTabBar.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ConcertSegmentTabBar: View {

    // MARK: - Property

    let selectedTab: ConcertDetailTab
    let communityCount: Int
    let onTabSelected: (ConcertDetailTab) -> Void

    @Namespace private var tabNamespace

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(ConcertDetailTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
        }
        .animation(.easeInOut, value: selectedTab)
        .frame(height: 48)
        .background(Color.livithColor(.black100))
    }
}

// MARK: - Tab Button

private extension ConcertSegmentTabBar {
    func tabButton(for tab: ConcertDetailTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            onTabSelected(tab)
        } label: {
            VStack(spacing: 0) {
                Spacer()

                tabLabel(for: tab, isSelected: isSelected)

                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 3)

                    if isSelected {
                        Rectangle()
                            .fill(Color.livithColor(.white100))
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "underline", in: tabNamespace)
                    }
                }
            }
        }
    }

    func tabLabel(for tab: ConcertDetailTab, isSelected: Bool) -> some View {
        Group {
            if tab == .community {
                HStack(spacing: 2) {
                    Text(tab.title)
                        .foregroundStyle(Color.livithColor(isSelected ? .white100 : .black50))

                    Text(" \(communityCount)")
                        .foregroundStyle(Color.livithColor(.yellow30))
                }
            } else {
                Text(tab.title)
                    .foregroundStyle(Color.livithColor(isSelected ? .white100 : .black50))
            }
        }
        .frame(width: 106, height: 56)
        .notosans(.body2Semibold)
    }
}

#Preview {
    ZStack {
        Color.livithColor(.black100)
            .ignoresSafeArea()

        VStack {
            ConcertSegmentTabBar(
                selectedTab: .artistDetail,
                communityCount: 0,
                onTabSelected: { _ in }
            )

            Spacer()
        }
    }
}
