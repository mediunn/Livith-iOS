//
//  ConcertInfoCarousel.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct ConcertInfoCarousel: View {

    // MARK: - Property

    @Environment(\.concertCoordinator) private var coordinator

    let concertInfoList: [ConcertInfo]
    let ticketingOfficeURL: URL?

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(Array(concertInfoList.enumerated()), id: \.offset) { index, info in
                concertInfoCard(info: info)
                    .opacity(index == currentIndex ? 1 : 0)
            }

            LivithPageIndicatorView(currentPage: currentIndex, pageCount: concertInfoList.count)
                .padding(.bottom, 18)
        }
        .frame(height: 274)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = ticketingOfficeURL {
                coordinator?.present(to: .ticketSafari(url))
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded(handleDragEnded)
        )
    }
}

// MARK: - Gesture

private extension ConcertInfoCarousel {
    func handleDragEnded(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let threshold: CGFloat = 50
        var newIndex = currentIndex

        if horizontalAmount < -threshold {
            newIndex = (currentIndex + 1) % concertInfoList.count
        } else if horizontalAmount > threshold {
            newIndex = (currentIndex - 1 + concertInfoList.count) % concertInfoList.count
        }

        if newIndex != currentIndex {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex = newIndex
            }
        }

        dragOffset = 0
    }
}

// MARK: - Subviews

private extension ConcertInfoCarousel {
    func concertInfoCard(info: ConcertInfo) -> some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .frame(height: 274)
                .frame(maxWidth: .infinity)
                .overlay {
                    AsyncImageView(
                        url: URL(string: info.imageURL),
                        showGradient: true
                    ) {
                        Color.livithColor(.black80)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 10) {
                LivithChip(info.title, style: .dark)

                Text(info.description)
                    .notosans(.body2Medium)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }
}

// MARK: - Preview

#Preview {
    ConcertInfoCarousel(
        concertInfoList: [
            ConcertInfo(
                id: 1,
                imageURL: "",
                title: "공연 입장 안내",
                description: "전석이 지정 좌석제로 운영\nFLOOR구역은 단차 없는 평지에 간이 의자가 설치되어있어 다른 구역은 계단식 좌석"
            ),
            ConcertInfo(
                id: 2,
                imageURL: "",
                title: "MD 판매 안내",
                description: "공연 당일 현장에서 MD를 구매하실 수 있습니다."
            )
        ],
        ticketingOfficeURL: URL(string: "https://tickets.interpark.com")
    )
    .background(Color.livithColor(.black100))
}
