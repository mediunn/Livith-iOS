//
//  ConcertInfoTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import LivithDesignSystem

struct ConcertInfoTabView: View {

    // MARK: - Property

    @Environment(\.concertCoordinator) private var coordinator

    let ticketingOffice: String?
    let ticketingOfficeURL: URL?
    let scheduleList: [ConcertSchedule]
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
                .padding(.horizontal, 16)

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
        if !scheduleList.isEmpty {
            VStack(alignment: .leading, spacing: 25) {
                SectionHeaderView(
                    firstLine: "날짜와 시간",
                    secondLine: "잊지 말고 확인해요"
                ) {
                    coordinator?.present(to: .safari(ConcertConstant.reportFormURL))
                }

                VStack(spacing: 34) {
                    ForEach(scheduleList) { schedule in
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
                coordinator?.present(to: .ticketSafari(ticketingOfficeURL))
            } label: {
                HStack(alignment: .top, spacing: 16) {
                    Image.livithIcon(.earth)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.livithColor(.black5))
                        .frame(width: 18, height: 18)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("티켓 웹사이트 바로가기")
                            .notosans(.body2Semibold)
                            .foregroundStyle(Color.livithColor(.white100))

                        Text("다시 방문하여 콘서트 소식을 한 눈에 확인해요")
                            .notosans(.body4Semibold)
                            .foregroundStyle(Color.livithColor(.black50))
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(Color.livithColor(.black80))
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

                ConcertInfoCarousel(
                    concertInfoList: concertInfoList,
                    ticketingOfficeURL: ticketingOfficeURL
                )
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
                        coordinator?.push(to: .merchandiseDetail(merchandiseList, ticketingOfficeURL: ticketingOfficeURL))
                    } label: {
                        Image.livithIcon(.rightLineDefault)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(merchandiseList) { merchandise in
                            LivithCard(
                                imageURL: merchandise.imageURL.flatMap { URL(string: $0) },
                                title: merchandise.name,
                                subtitle: merchandise.price
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        ConcertInfoTabView(
            ticketingOffice: "인터파크",
            ticketingOfficeURL: URL(string: "https://tickets.interpark.com"),
            scheduleList: [
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
            concertInfoList: [
                ConcertInfo(
                    id: 1,
                    imageURL: "https://ticketimage.interpark.com/Play/image/large/25/25012412_p.gif",
                    title: "공연 입장 안내",
                    description: "전석이 지정 좌석제로 운영\nFLOOR구역은 단차 없는 평지에 간이 의자가 설치되어있어 다른 구역은 계단식 좌석"
                ),
                ConcertInfo(
                    id: 1,
                    imageURL: "https://ticketimage.interpark.com/Play/image/large/25/25012412_p.gif",
                    title: "공연 입장 안내",
                    description: "전석이 지정 좌석제로 운영\nFLOOR구역은 단차 없는 평지에 간이 의자가 설치되어있어 다른 구역은 계단식 좌석"
                )
            ],
            merchandiseList: [
                ConcertMerchandise(id: 1, name: "제품이름", price: "가격", imageURL: nil),
                ConcertMerchandise(id: 2, name: "제품이름", price: "가격", imageURL: nil),
                ConcertMerchandise(id: 3, name: "제품이름", price: "가격", imageURL: nil),
                ConcertMerchandise(id: 3, name: "제품이름", price: "가격", imageURL: nil)
            ]
        )
    }
    .background(Color.livithColor(.black100))
}
