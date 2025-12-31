//
//  ArtistDetailTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct ArtistDetailTabView: View {

    // MARK: - Property

    @Environment(\.concertCoordinator) private var coordinator
    
    let artist: Artist?
    let introduction: String
    let fanCultures: [ConcertCulture]

    // MARK: - Body

    private var hasNoContent: Bool {
        let hasIntroduction = !introduction.isEmpty
        let hasArtist = artist != nil && !artist!.name.isEmpty
        let hasFanCultures = !fanCultures.isEmpty
        return !hasIntroduction && !hasArtist && !hasFanCultures
    }

    var body: some View {
        if hasNoContent {
            LivithEmptyView(text: "가수 정보가 없어요")
                .frame(maxWidth: .infinity)
                .padding(.top, 98)
        } else {
            VStack(spacing: 30) {
                introductionSection
                    .padding(.horizontal, 16)

                artistInfoSection
                    .padding(.horizontal, 16)

                fanCultureSection
            }
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Introduction Section

private extension ArtistDetailTabView {
    var introductionSection: some View {
        ConcertIntroductionCard(introduction: introduction)
    }
}

// MARK: - Artist Info Section

private extension ArtistDetailTabView {
    @ViewBuilder
    var artistInfoSection: some View {
        if let artist, !artist.name.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                SectionHeaderView(
                    firstLine: "아티스트 정보",
                    secondLine: "함께 알아볼까요?"
                ) {
                    coordinator?.present(to: .safari(ConcertConstant.reportFormURL))
                }
                .padding(.bottom, 20)

                artistInfoCard(for: artist)
                    .padding(.bottom, 10)

                tagsView(keywords: artist.keywords)
            }
        }
    }

    func artistInfoCard(for artist: Artist) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageURLString = artist.imageURL {
                AsyncImageView(url: URL(string: imageURLString))
                    .frame(height: 148)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 8,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 8
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 0) {
                if !artist.category.isEmpty {
                    artistTag(category: artist.category)
                        .padding(.bottom, 8)
                }

                artistNameRow(for: artist)
                    .padding(.bottom, 12)

                dashedDivider
                    .padding(.bottom, 12)

                Text(artist.detail)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.bottom, 20)

                debutYearRow(year: artist.debutYear)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func artistTag(category: String) -> some View {
        Text(category)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black50))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.livithColor(.black100))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    func artistNameRow(for artist: Artist) -> some View {
        HStack {
            Text(artist.name)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            if let instagramURLString = artist.instagramURL,
               let instagramURL = URL(string: instagramURLString) {
                Button {
                    coordinator?.present(to: .safari(instagramURL))
                } label: {
                    Image.livithImage(.instagram)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
        }
    }

    func debutYearRow(year: String) -> some View {
        HStack(spacing: 8) {
            Text("데뷔")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))

            Text(year)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }

    func tagsView(keywords: [String]) -> some View {
        FlowLayout(spacing: 4) {
            ForEach(keywords, id: \.self) { keyword in
                TagChipView(text: keyword)
            }
        }
    }
}

// MARK: - Line Shape

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// MARK: - Fan Culture Section

private extension ArtistDetailTabView {
    @ViewBuilder
    var fanCultureSection: some View {
        if !fanCultures.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(
                    badgeCount: fanCultures.count,
                    firstLine: "의 팬문화와",
                    secondLine: "꿀팁을 알아봐요"
                ) {
                    coordinator?.present(to: .safari(ConcertConstant.reportFormURL))
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(Array(fanCultures.enumerated()), id: \.element.id) { index, culture in
                            fanCultureCard(index: index + 1, culture: culture)
                                .padding(.leading, index == 0 ? 16 : 0)
                                .padding(.trailing, index == fanCultures.count - 1 ? 16 : 0)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    func fanCultureCard(index: Int, culture: ConcertCulture) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("팬문화 \(index)")
                .notosans(.caption1Bold)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.livithColor(.black100))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.bottom, 4)

            Text(culture.title)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.bottom, 12)

            dashedDivider
                .padding(.bottom, 12)

            Text(culture.content)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))

            Spacer(minLength: 0)
        }
        .frame(width: 200, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(16)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Common Components

private extension ArtistDetailTabView {
    var dashedDivider: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundStyle(Color.livithColor(.black50))
            .frame(height: 1)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ArtistDetailTabView(
            artist: Artist(
                id: 1,
                name: "HOSHINO GEN",
                debutYear: "1981년",
                category: "일본 내한 가수",
                imageURL: nil,
                detail: "단순한 가수를 넘어, 연기, 음악, 글쓰기, 라디오 등 다방면에서 활약하는 일본의 대표적인 크리에이터",
                keywords: ["다채로운 사운드", "팝", "재즈"],
                instagramURL: "https://instagram.com/iamgenhoshino"
            ),
            introduction: "호시노 겐의 n 년만의 내한!\nKoi 열풍으로 한국에서도 인기 아티스트",
            fanCultures: [
                ConcertCulture(id: 1, concertID: 1, title: "겐짱 문화", content: "한줄일땐이렇게표시가됩니다!!!"),
                ConcertCulture(id: 2, concertID: 1, title: "Koi 단체 댄스", content: "한줄일땐이렇게표시가됩니다!!\n줄일땐이렇게표시가!!")
            ]
        )
    }
    .background(Color.livithColor(.black100))
}
