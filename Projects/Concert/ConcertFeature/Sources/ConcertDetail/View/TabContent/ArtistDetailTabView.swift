//
//  ArtistDetailTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct ArtistDetailTabView: View {

    // MARK: - Property

    let introduction: String

    // TODO: 실제 API 연동 시 아티스트 데이터로 교체
    private let mockArtist = MockArtist(
        name: "HOSINO GEN",
        country: "일본 내한 가수",
        description: "단순한 가수를 넘어, 연기, 음악, 글쓰기, 라디오 등 다방면에서 활약하는 일본의 대표적인 크리에이터",
        debutYear: "1981년",
        imageURL: URL(string: "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2F5qhwt%2FbtsJMBn1RWf%2FAAAAAAAAAAAAAAAAAAAAAOvELz7uPGfEY6OIC4_JQ08HHV5mE_l0Cqu78SlQdqI5%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1767193199%26allow_ip%3D%26allow_referer%3D%26signature%3DJrAEIyExN4mhW9KDoPKLzBEt5DA%253D"),
        instagramURL: URL(string: "https://instagram.com/iamgenhoshino"),
        tags: ["다채로운 사운드", "팝", "재즈", "펑크", "시티팝", "R&B", "따뜻한 멜로디", "사소한 일상의 감정을 섬세하게", "독특한 \"겐 감성\""]
    )

    private let mockFanCultures = [
        MockFanCulture(title: "겐짱 문화", description: "한줄일땐이렇게표시가됩니다!!!그"),
        MockFanCulture(title: "Koi 단체 댄스", description: "한줄일땐이렇게표시가됩니다!!그\n줄일땐이렇게표시가!!")
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 30) {
            introductionSection

            artistInfoSection

            fanCultureSection
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
        .padding(.bottom, 40)
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
    var artistInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 20) {
                sectionHeader(
                    firstLine: "아티스트 정보",
                    secondLine: "함께 알아볼까요?"
                )

                artistInfoCard(imageURL: mockArtist.imageURL)
            }
            
            tagsView
        }
    }

    @ViewBuilder
    func artistInfoCard(imageURL: URL?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let url = imageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.livithColor(.black80)
                }
                .frame(height: 148)
                .clipped()
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
                artistTag
                    .padding(.bottom, 12)

                artistNameRow
                    .padding(.bottom, 16)

                dashedDivider
                    .padding(.bottom, 12)

                Text(mockArtist.description)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.bottom, 20)

                debutYear
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.livithColor(.black90))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    var artistTag: some View {
        Text(mockArtist.country)
            .notosans(.caption1Semibold)
            .foregroundStyle(Color.livithColor(.black50))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Color.livithColor(.black100))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    var artistNameRow: some View {
        HStack {
            Text(mockArtist.name)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))

            Spacer()

            // TODO: 인스타그램 아이콘 에셋 추가 후 주석 해제
            // if let instagramURL = mockArtist.instagramURL {
            //     Link(destination: instagramURL) {
            //         Image.livithIcon(.instagramLine)
            //             .resizable()
            //             .frame(width: 32, height: 32)
            //     }
            // }
        }
    }

    var debutYear: some View {
        HStack(spacing: 8) {
            Text("데뷔")
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black50))

            Text(mockArtist.debutYear)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
        }
    }

    var tagsView: some View {
        FlowLayout(spacing: 4) {
            ForEach(mockArtist.tags, id: \.self) { tag in
                TagChipView(text: tag)
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
    var fanCultureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                badgeCount: mockFanCultures.count,
                firstLine: "의 팬문화와",
                secondLine: "꿀팁을 알아봐요"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(mockFanCultures.enumerated()), id: \.offset) { index, culture in
                        fanCultureCard(index: index + 1, culture: culture)
                    }
                }
            }
        }
    }

    func fanCultureCard(index: Int, culture: MockFanCulture) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("팬문화 \(index)")
                .notosans(.caption1Semibold)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.livithColor(.black100))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.bottom, 12)

            Text(culture.title)
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.bottom, 16)

            dashedDivider
                .padding(.bottom, 12)

            Text(culture.description)
                .notosans(.body4Medium)
                .foregroundStyle(Color.livithColor(.black30))
                .lineLimit(2)
        }
        .frame(width: 200, alignment: .leading)
        .padding(16)
        .background(Color.livithColor(.black80))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Common Components

private extension ArtistDetailTabView {
    func sectionHeader(
        badgeCount: Int? = nil,
        firstLine: String,
        secondLine: String
    ) -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 4) {
                    if let count = badgeCount {
                        badgeText(count: count)
                    }

                    Text(firstLine)
                        .notosans(.body1Semibold)
                        .foregroundStyle(Color.livithColor(.white100))
                }

                Text(secondLine)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
            }

            Spacer()

            reportButton
        }
    }

    var reportButton: some View {
        Button {
            // TODO: 정보 제보 액션
        } label: {
            Text("정보 제보")
                .notosans(.caption1Semibold)
                .foregroundStyle(Color.livithColor(.black50))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.livithColor(.black80), lineWidth: 1)
                )
        }
    }

    func badgeText(count: Int) -> some View {
        Text("\(count)개")
            .notosans(.body1Semibold)
            .foregroundStyle(Color.livithColor(.black100))
            .padding(.horizontal, 8)
            .padding(.vertical, 1)
            .background(Color.livithColor(.yellow30))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    var dashedDivider: some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
            .foregroundStyle(Color.livithColor(.black50))
            .frame(height: 1)
    }
}

// MARK: - Mock Models

private struct MockArtist {
    let name: String
    let country: String
    let description: String
    let debutYear: String
    let imageURL: URL?
    let instagramURL: URL?
    let tags: [String]
}

private struct MockFanCulture {
    let title: String
    let description: String
}

// MARK: - Preview

#Preview {
    ScrollView {
        ArtistDetailTabView(
            introduction: "호시노 겐의 n 년만의 내한!\nKoi 열풍으로 한국에서도 인기 아티스트"
        )
    }
    .background(Color.livithColor(.black100))
}
