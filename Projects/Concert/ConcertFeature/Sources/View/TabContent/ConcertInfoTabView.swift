//
//  ConcertInfoTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct ConcertInfoTabView: View {

    // MARK: - Property

    @Environment(\.concertCoordinator) private var coordinator

    let schedules: [ConcertSchedule]
    let ticketingOffice: String?
    let ticketingOfficeURL: URL?
    let concertInfoList: [ConcertInfo]
    let merchandiseList: [ConcertMerchandise]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 30) {
            scheduleSection
                .padding(.horizontal, 16)

            ticketWebsiteCard
                .padding(.horizontal, 16)

            concertInfoSection

            merchandiseSection
        }
        .padding(.top, 30)
        .padding(.bottom, 40)
    }
}

// MARK: - Schedule Section

private extension ConcertInfoTabView {
    @ViewBuilder
    var scheduleSection: some View {
        if !schedules.isEmpty {
            VStack(alignment: .leading, spacing: 25) {
                SectionHeaderView(
                    firstLine: "날짜와 시간",
                    secondLine: "잊지 말고 확인해요"
                ) {
                    coordinator?.present(to: .safari(ConcertConstant.reportFormURL))
                }

                VStack(spacing: 34) {
                    ForEach(schedules) { schedule in
                        ScheduleRowView(schedule: schedule)
                    }
                }
            }
        }
    }
}

// MARK: - Ticket Website Card

private extension ConcertInfoTabView {
    @ViewBuilder
    var ticketWebsiteCard: some View {
        if let ticketingOfficeURL {
            Button {
                coordinator?.present(to: .safari(ticketingOfficeURL))
            } label: {
                HStack(spacing: 12) {
                    Image.livithIcon(.earth)
                        .resizable()
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("티켓 웹사이트 바로가기")
                            .notosans(.body3Semibold)
                            .foregroundStyle(Color.livithColor(.white100))

                        Text("다시 방문하여 콘서트 소식을 한 눈에 확인해요")
                            .notosans(.caption1Regular)
                            .foregroundStyle(Color.livithColor(.black50))
                    }

                    Spacer()
                }
                .padding(16)
                .background(Color.livithColor(.black90))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Concert Info Section

private extension ConcertInfoTabView {
    @ViewBuilder
    var concertInfoSection: some View {
        if !concertInfoList.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeaderView(
                    firstLine: "콘서트 필수 정보",
                    secondLine: "빠르게 확인해요"
                ) {
                    coordinator?.present(to: .safari(ConcertConstant.reportFormURL))
                }
                .padding(.horizontal, 16)

                ConcertInfoCarousel(concertInfoList: concertInfoList)
            }
        }
    }
}

// MARK: - Merchandise Section

private extension ConcertInfoTabView {
    @ViewBuilder
    var merchandiseSection: some View {
        if !merchandiseList.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeaderView(
                    badgeCount: merchandiseList.count,
                    badgeSuffix: "건",
                    firstLine: "의 MD 정보를",
                    secondLine: "한 눈에 확인해요"
                ) {
                    Button {
                        // TODO: MD 상세 화면으로 이동
                    } label: {
                        Image.livithIcon(.rightLineDefault)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(merchandiseList.enumerated()), id: \.element.id) { index, merchandise in
                            merchandiseCard(merchandise: merchandise)
                                .padding(.leading, index == 0 ? 16 : 0)
                                .padding(.trailing, index == merchandiseList.count - 1 ? 16 : 0)
                        }
                    }
                }
            }
        }
    }

    func merchandiseCard(merchandise: ConcertMerchandise) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURLString = merchandise.imageURL,
               let url = URL(string: imageURLString) {
                AsyncImageView(url: url)
                    .frame(width: 108, height: 158)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.livithColor(.black80))
                    .frame(width: 108, height: 158)
            }

            Text(merchandise.name)
                .notosans(.body2Medium)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)

            if let price = merchandise.price {
                Text(price)
                    .notosans(.caption1Semibold)
                    .foregroundStyle(Color.livithColor(.black50))
            }
        }
    }
}

// MARK: - Info Carousel

private struct ConcertInfoCarousel: View {
    let concertInfoList: [ConcertInfo]
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                ForEach(Array(concertInfoList.enumerated()), id: \.element.id) { index, info in
                    concertInfoCard(info: info)
                        .opacity(index == currentIndex ? 1 : 0)
                }
            }
            .frame(height: 280)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if value.translation.width < -threshold {
                                currentIndex = min(currentIndex + 1, concertInfoList.count - 1)
                            } else if value.translation.width > threshold {
                                currentIndex = max(currentIndex - 1, 0)
                            }
                        }
                    }
            )
        }
        .padding(.horizontal, 16)
    }

    func concertInfoCard(info: ConcertInfo) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImageView(
                url: URL(string: info.imageURL),
                showGradient: true
            ) {
                Color.livithColor(.black80)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 274)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                CardTagView(info.title, fontStyle: .caption1Semibold)

                Text(info.description)
                    .notosans(.body3Medium)
                    .foregroundStyle(Color.livithColor(.white100))
                    .lineLimit(3)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
            
            LivithPageIndicator(currentPage: currentIndex, pageCount: concertInfoList.count)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 18)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ConcertInfoTabView(
            schedules: [
                ConcertSchedule(
                    id: 1,
                    category: "티켓팅 오픈",
                    scheduledAt: Date().addingTimeInterval(86400),
                    type: .ticketing
                ),
                ConcertSchedule(
                    id: 2,
                    category: "MD 오픈",
                    scheduledAt: Date().addingTimeInterval(86400 * 30),
                    type: .none
                ),
                ConcertSchedule(
                    id: 3,
                    category: "첫 날 콘서트",
                    scheduledAt: Date().addingTimeInterval(86400 * 81),
                    type: .none
                )
            ],
            ticketingOffice: "인터파크",
            ticketingOfficeURL: URL(string: "https://tickets.interpark.com"),
            concertInfoList: [
                ConcertInfo(
                    id: 1,
                    imageURL: "",
                    title: "공연 입장 안내",
                    description: "전석이 지정 좌석제로 운영\nFLOOR구역은 단차 없는 평지에 간이 의자가 설치되어있어 다른 구역은 계단식 좌석"
                ),
                ConcertInfo(
                    id: 1,
                    imageURL: "",
                    title: "공연 입장 안내",
                    description: "전석이 지정 좌석제로 운영\nFLOOR구역은 단차 없는 평지에 간이 의자가 설치되어있어 다른 구역은 계단식 좌석"
                )
            ],
            merchandiseList: [
                ConcertMerchandise(id: 1, name: "제품이름", price: "가격", imageURL: nil),
                ConcertMerchandise(id: 2, name: "제품이름", price: "가격", imageURL: nil),
                ConcertMerchandise(id: 3, name: "제품이름", price: "가격", imageURL: nil)
            ]
        )
    }
    .background(Color.livithColor(.black100))
}
