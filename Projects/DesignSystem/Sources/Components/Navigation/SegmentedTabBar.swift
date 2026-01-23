//
//  SegmentedTabBar.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Tab Type

public enum SegmentedTabBarType {
    case home(selectedTab: HomeTab, onTabSelected: (HomeTab) -> Void)
    case detail(selectedTab: DetailTab, communityCount: Int, onTabSelected: (DetailTab) -> Void)

    public enum HomeTab: Int, CaseIterable {
        case schedule
        case setlist

        var title: String {
            switch self {
            case .schedule: return "콘서트 일정"
            case .setlist: return "셋리스트"
            }
        }
    }

    public enum DetailTab: Int, CaseIterable {
        case artistDetail
        case concertInfo
        case setlist
        case community

        var title: String {
            switch self {
            case .artistDetail: return "아티스트 상세"
            case .concertInfo: return "콘서트 상세"
            case .setlist: return "셋리스트"
            case .community: return "소통·댓글"
            }
        }
    }

    var isScrollable: Bool {
        switch self {
        case .home: return false
        case .detail: return true
        }
    }

    var tabWidth: CGFloat? {
        switch self {
        case .home: return nil
        case .detail: return 106
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .home: return 20
        case .detail: return 16
        }
    }

    var tabs: [TabItem] {
        switch self {
        case .home(let selectedTab, _):
            return HomeTab.allCases.map {
                TabItem(id: $0.rawValue, title: $0.title, isSelected: $0 == selectedTab, badge: nil)
            }
        case .detail(let selectedTab, let communityCount, _):
            return DetailTab.allCases.map {
                TabItem(
                    id: $0.rawValue,
                    title: $0.title,
                    isSelected: $0 == selectedTab,
                    badge: $0 == .community ? communityCount : nil
                )
            }
        }
    }

    var selectedIndex: Int {
        switch self {
        case .home(let selectedTab, _): return selectedTab.rawValue
        case .detail(let selectedTab, _, _): return selectedTab.rawValue
        }
    }

    func onSelect(_ index: Int) {
        switch self {
        case .home(_, let onTabSelected):
            if let tab = HomeTab(rawValue: index) { onTabSelected(tab) }
        case .detail(_, _, let onTabSelected):
            if let tab = DetailTab(rawValue: index) { onTabSelected(tab) }
        }
    }
}

// MARK: - Tab Item

struct TabItem: Identifiable {
    let id: Int
    let title: String
    let isSelected: Bool
    let badge: Int?
}

// MARK: - SegmentedTabBar

public struct SegmentedTabBar: View {

    // MARK: - Property

    private let type: SegmentedTabBarType

    @Namespace private var tabNamespace

    // MARK: - Initializer

    public init(type: SegmentedTabBarType) {
        self.type = type
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottom) {
            Divider()
                .frame(height: 3)
                .background(.livithColor(.black90))

            tabBarContent
        }
        .background(.livithColor(.black100))
    }
}

// MARK: - Content

private extension SegmentedTabBar {
    var tabBarContent: some View {
        Group {
            if type.isScrollable {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        tabButtons
                    }
                    .onChange(of: type.selectedIndex) { _, newIndex in
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            } else {
                tabButtons
            }
        }
        .animation(.easeInOut, value: type.selectedIndex)
    }

    var tabButtons: some View {
        HStack(spacing: 0) {
            ForEach(type.tabs) { tab in
                tabButton(tab: tab)
                    .id(tab.id)
            }
        }
    }

    func tabButton(tab: TabItem) -> some View {
        Button {
            type.onSelect(tab.id)
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 2) {
                    Text(tab.title)
                        .foregroundStyle(Color.livithColor(tab.isSelected ? .white100 : .black50))

                    if let badge = tab.badge, badge > 0 {
                        Text(" \(badge)")
                            .foregroundStyle(Color.livithColor(.yellow30))
                    }
                }
                .notosans(.body2Semibold)
                .frame(width: type.tabWidth)
                .fixedSize(horizontal: type.tabWidth == nil, vertical: false)
                .padding(.vertical, type.verticalPadding)

                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 3)

                    if tab.isSelected {
                        Rectangle()
                            .fill(Color.livithColor(.white100))
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "underline", in: tabNamespace)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Home") {
    struct PreviewContainer: View {
        @State var selectedTab: SegmentedTabBarType.HomeTab = .schedule

        var body: some View {
            ZStack {
                Color.livithColor(.black100)
                    .ignoresSafeArea()

                VStack {
                    SegmentedTabBar(type: .home(
                        selectedTab: selectedTab,
                        onTabSelected: { selectedTab = $0 }
                    ))

                    Text("선택된 탭: \(selectedTab.title)")
                        .foregroundStyle(.livithColor(.white100))
                        .padding(.top, 20)

                    Spacer()
                }
            }
        }
    }

    return PreviewContainer()
}

#Preview("Detail") {
    struct PreviewContainer: View {
        @State var selectedTab: SegmentedTabBarType.DetailTab = .artistDetail

        var body: some View {
            ZStack {
                Color.livithColor(.black100)
                    .ignoresSafeArea()

                VStack {
                    SegmentedTabBar(type: .detail(
                        selectedTab: selectedTab,
                        communityCount: 15,
                        onTabSelected: { selectedTab = $0 }
                    ))

                    Text("선택된 탭: \(selectedTab.title)")
                        .foregroundStyle(.livithColor(.white100))
                        .padding(.top, 20)

                    Spacer()
                }
            }
        }
    }

    return PreviewContainer()
}
