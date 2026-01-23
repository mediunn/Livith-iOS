//
//  RecommendKeywordListView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct RecommendKeywordListView: View {
    private let searchText: String
    private let keywordList: [String]
    private let onTap: (String) -> Void

    init(
        searchText: String,
        keywordList: [String],
        onTap: @escaping (String) -> Void
    ) {
        self.searchText = searchText
        self.keywordList = keywordList
        self.onTap = onTap
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(keywordList, id: \.self) { keyword in
                        keywordButton(keyword)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Subviews

private extension RecommendKeywordListView {
    func keywordButton(_ keyword: String) -> some View {
        Button {
            onTap(keyword)
        } label: {
            Text(styledKeyword(keyword))
                .notosans(.body3Medium)
        }
    }
}

// MARK: - Styling

private extension RecommendKeywordListView {
    func styledKeyword(_ keyword: String) -> AttributedString {
        var attributed = AttributedString(keyword)
        guard !keyword.isEmpty else { return attributed }
        
        applyBaseStyle(to: &attributed)
        highlightSearchText(in: &attributed)
        
        return attributed
    }
    
    func applyBaseStyle(to attributed: inout AttributedString) {
        let range = attributed.startIndex..<attributed.endIndex
        let font = Font.Notosans.body4Regular
        
        attributed[range].font = .notosans(font)
        attributed[range].kern = font.kerning
        attributed[range].foregroundColor = .livithColor(.black50)
    }
    
    func highlightSearchText(in attributed: inout AttributedString) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let matchRange = attributed.range(of: trimmed, options: [.caseInsensitive]) else {
            return
        }
        
        let font = Font.Notosans.body4Semibold
        attributed[matchRange].font = .notosans(font)
        attributed[matchRange].kern = font.kerning
        attributed[matchRange].foregroundColor = .livithColor(.white100)
    }
}

#Preview {
    VStack(spacing: 24) {
        RecommendKeywordListView(
            searchText: "호",
            keywordList: ["호드플레이", "호라", "호시노겐"],
            onTap: { print("Tapped: \($0)") }
        )
        .background(Color.livithColor(.black100))

        RecommendKeywordListView(
            searchText: "ho",
            keywordList: ["Homeplay", "Honora", "Hoshinogen"],
            onTap: { print("Tapped ENG: \($0)") }
        )
        .background(Color.livithColor(.black100))
    }
}
