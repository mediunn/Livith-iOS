//
//  LyricsContentView.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import LivithDesignSystem

struct TextSegment {
    let text: String
    let isHighlighted: Bool
}

struct ParsedText {
    let segments: [TextSegment]
}

struct LyricsContentView: View {

    // MARK: - Property

    @ObservedObject var store: SongLyricsStore

    private var lyrics: [String] {
        store.state.lyrics?.lyrics ?? []
    }

    private var pronunciation: [String] {
        store.state.lyrics?.pronunciation ?? []
    }

    private var translation: [String] {
        store.state.lyrics?.translation ?? []
    }

    private var fanchant: [String] {
        store.state.fanchant?.fanchant ?? []
    }

    private var maxLineCount: Int {
        max(lyrics.count, pronunciation.count, translation.count, fanchant.count)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: 36)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if store.state.hasFanchantPoint {
                        fanchantPointSection

                        divideLine
                    }

                    lyricsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Subviews

private extension LyricsContentView {
    var fanchantPointSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("떼창 포인트")
                .notosans(.body4Semibold)
                .foregroundStyle(Color.livithColor(.yellow30))

            Text(store.state.fanchant?.fanchantPoint ?? "")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 36)
    }
    
    var divideLine: some View {
        Divider()
            .background(Color.livithColor(.black80))
            .frame(height: 2)
            .padding(.bottom, 30)
    }

    var lyricsSection: some View {
        VStack(alignment: .leading, spacing: 44) {
            ForEach(0..<maxLineCount, id: \.self) { index in
                lyricsLineView(at: index)
            }
        }
    }

    func lyricsLineView(at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            if store.state.showOriginal, index < lyrics.count {
                if store.state.showFanchant, index < fanchant.count {
                    hashHighlightedText(
                        fanchant[index],
                        defaultColor: Color.livithColor(.original),
                        highlightColor: Color.livithColor(.yellow30)
                    )
                } else {
                    lyricsText(lyrics[index], color: Color.livithColor(.original))
                }
            } else if store.state.showFanchant, index < fanchant.count {
                hashHighlightedText(
                    fanchant[index],
                    defaultColor: Color.livithColor(.yellow30),
                    highlightColor: Color.livithColor(.white100)
                )
            }

            if store.state.showPronunciation, index < pronunciation.count {
                lyricsText(pronunciation[index], color: Color.livithColor(.white100))
            }

            if store.state.showTranslation, index < translation.count {
                lyricsText(translation[index], color: Color.livithColor(.translation))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func lyricsText(_ text: String, color: Color) -> some View {
        Text(text)
            .notosans(.body2Medium)
            .foregroundStyle(color)
    }

    @ViewBuilder
    func hashHighlightedText(_ text: String, defaultColor: Color, highlightColor: Color) -> some View {
        let parsed = parseHashText(text)

        if parsed.segments.isEmpty {
            Text(text)
                .notosans(.body2Regular)
                .foregroundStyle(defaultColor)
        } else {
            Text(parsed.segments.reduce(into: AttributedString()) { result, segment in
                var attributedSegment = AttributedString(segment.text)
                attributedSegment.foregroundColor = segment.isHighlighted ? highlightColor : defaultColor
                result.append(attributedSegment)
            })
            .notosans(.body2Regular)
        }
    }
}

// MARK: - Helper Method

private extension LyricsContentView {
    func parseHashText(_ text: String) -> ParsedText {
        var segments: [TextSegment] = []
        var remaining = text

        while let startRange = remaining.range(of: "##") {
            let beforeHash = String(remaining[..<startRange.lowerBound])
            if !beforeHash.isEmpty {
                segments.append(TextSegment(text: beforeHash, isHighlighted: false))
            }

            remaining = String(remaining[startRange.upperBound...])

            if let endRange = remaining.range(of: "##") {
                let highlighted = String(remaining[..<endRange.lowerBound])
                segments.append(TextSegment(text: highlighted, isHighlighted: true))
                remaining = String(remaining[endRange.upperBound...])
            } else {
                segments.append(TextSegment(text: "##" + remaining, isHighlighted: false))
                remaining = ""
            }
        }

        if !remaining.isEmpty {
            segments.append(TextSegment(text: remaining, isHighlighted: false))
        }

        return ParsedText(segments: segments)
    }
}


#Preview {
    LyricsContentView(store: SongLyricsStore())
        .background(Color.livithColor(.black100))
}
