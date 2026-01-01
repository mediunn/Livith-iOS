//
//  SegmentTabBar.swift
//  DSKit
//
//  Created by 김진웅 on 1/1/26.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

/// 일반화된 세그먼트 탭 바 컴포넌트
/// - Parameters:
///   - segmentTitles: 표시할 세그먼트 제목 배열
///   - selectedIndex: 현재 선택된 탭 인덱스 (상태 변수)
///   - onTabSelected: 탭 선택 시 콜백 (선택된 인덱스 전달)
public struct SegmentTabBar: View {
    
    let segmentTitles: [String]
    let selectedIndex: Int
    let onTabSelected: (Int) -> Void
    
    @Namespace private var tabNamespace
    
    public init(
        segmentTitles: [String],
        selectedIndex: Int,
        onTabSelected: @escaping (Int) -> Void,
    ) {
        self.segmentTitles = segmentTitles
        self.selectedIndex = selectedIndex
        self.onTabSelected = onTabSelected
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Divider()
                .frame(height: Constants.borderWidth)
                .background(.livithColor(.black90))
            
            HStack(spacing: 0) {
                ForEach(0..<segmentTitles.count, id: \.self) { index in
                    tabButton(for: index)
                        .id(index)
                }
            }
        }
        .animation(.easeInOut, value: selectedIndex)
        .background(.livithColor(.black100))
    }
    
    
}

// MARK: - Tab Button

private extension SegmentTabBar {
    func tabButton(for index: Int) -> some View {
        let isSelected = selectedIndex == index
        let title = segmentTitles[index]
        
        return Button {
            onTabSelected(index)
        } label: {
            VStack(spacing: 0) {
                tabLabel(title: title, isSelected: isSelected)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: Constants.borderWidth)
                    
                    if isSelected {
                        Rectangle()
                            .fill(Color.livithColor(.white100))
                            .frame(height: Constants.borderWidth)
                            .matchedGeometryEffect(id: "underline", in: tabNamespace)
                    }
                }
            }
        }
    }
    
    func tabLabel(title: String, isSelected: Bool) -> some View {
        Text(title)
            .foregroundStyle(Color.livithColor(isSelected ? .white100 : .black50))
            .notosans(.body2Semibold)
            .fixedSize(horizontal: true, vertical: false)
    }
}

// MARK: - Constants

private extension SegmentTabBar {
    enum Constants {
        static let borderWidth: CGFloat = 4
    }
}


#Preview {
    struct PreviewContainer: View {
        @State var selectedIndex: Int = 0
        
        var body: some View {
            ZStack {
                Color.livithColor(.black100)
                    .ignoresSafeArea()
                
                VStack {
                    SegmentTabBar(
                        segmentTitles: ["콘서트 일정", "셋리스트"],
                        selectedIndex: selectedIndex,
                        onTabSelected: { index in
                            selectedIndex = index
                        }
                    )
                    
                    Text("선택된 탭: \(selectedIndex)")
                        .foregroundStyle(.livithColor(.white100))
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
    }
    
    return PreviewContainer()
}
