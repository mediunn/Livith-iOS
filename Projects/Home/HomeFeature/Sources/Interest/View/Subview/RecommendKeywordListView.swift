//
//  RecommendKeywordListView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

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
        VStack(alignment: .leading, spacing: 24) {
            ForEach(keywordList, id: \.self) { keyword in
                    keywordText(keyword)
            }
        }
    }
}

// MARK: - Private Builders

private extension RecommendKeywordListView {
    @ViewBuilder
    func keywordText(_ keyword: String) -> some View {
        Button {
            onTap(keyword)
        } label: {
            let attributed = styled(keyword: keyword)
            Text(attributed)
                .notosans(.body3Medium)
        }
    }

    func styled(keyword: String) -> AttributedString {
        var attributed = AttributedString(keyword)
        guard !keyword.isEmpty else { return attributed }

        let baseRange = attributed.startIndex..<attributed.endIndex
        let font = Font.Notosans.body4Regular
        attributed[baseRange].font = .notosans(font)
        attributed[baseRange].kern = font.kerning
        attributed[baseRange].foregroundColor = .livithColor(.black50)
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty,
           let matchRange = attributed.range(of: trimmed, options: [.caseInsensitive]) {
            let font = Font.Notosans.body4Semibold
            attributed[matchRange].font = .notosans(font)
            attributed[baseRange].kern = font.kerning
            attributed[matchRange].foregroundColor = .livithColor(.white100)
        }

        return attributed
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
