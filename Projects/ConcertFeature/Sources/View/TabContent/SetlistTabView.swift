//
//  SetlistTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem
import LivithFoundation

struct SetlistTabView: View {

    // MARK: - Property

    @Environment(\.concertCoordinator) private var coordinator

    let concertID: Int
    let setlistList: [Setlist]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10, alignment: .top),
        count: 3
    )

    // MARK: - Body

    var body: some View {
        if setlistList.isEmpty {
            emptyView
        } else {
            setlistContent
        }
    }
}

// MARK: - Empty View

private extension SetlistTabView {
    var emptyView: some View {
        LivithEmptyView(text: "셋리스트가 없어요")
            .frame(maxWidth: .infinity)
            .frame(height: 300)
    }
}

// MARK: - Setlist Content

private extension SetlistTabView {
    var setlistContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeaderView(
                firstLine: "셋리스트를",
                secondLine: "확인해 보세요"
            ) {
                AmplitudeService.shared.trackEvent(tag: .click(.reportSetlistSection))
                coordinator?.present(to: .safari(ConcertConstant.reportFormURL))
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(setlistList) { setlist in
                    setlistCard(for: setlist)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
        .padding(.bottom, 40)
    }

    func setlistCard(for setlist: Setlist) -> some View {
        Button {
            AmplitudeService.shared.trackEvent(tag: .click(.setlistCell))
            coordinator?.push(to: .setlistDetail(concertID: concertID, setlistID: setlist.id))
        } label: {
            LivithCard(
                imageURL: setlist.imageURL,
                title: setlist.title,
                subtitle: formatDate(setlist),
                badge: (setlist.status == .recent || setlist.status == .expected) ? .tag(text: setlist.status?.description ?? "") : .none,
                isFlexible: true,
                titleLineLimit: 2
            )
        }
        .buttonStyle(.plain)
    }

    func formatDate(_ setlist: Setlist) -> String {
        DateFormatter.formatDateRange(from: setlist.startDate, to: setlist.endDate)
    }
}

#Preview {
    ScrollView {
        SetlistTabView(
            concertID: 1,
            setlistList: [
                Setlist(
                    id: 1,
                    title: "Gen Hoshino presents MAD HOPE 202",
                    imageURL: nil,
                    type: .expected,
                    status: nil,
                    startDate: Date(),
                    endDate: Date(),
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                ),
                Setlist(
                    id: 2,
                    title: "World Tour [ LIVE FULL E...",
                    imageURL: nil,
                    type: .recent,
                    status: nil,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400),
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                ),
                Setlist(
                    id: 3,
                    title: "World Tour [ LIVE FULL E...",
                    imageURL: nil,
                    type: .recent,
                    status: nil,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400),
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                ),
                Setlist(
                    id: 4,
                    title: "World Tour [ LIVE FULL E...",
                    imageURL: nil,
                    type: .none,
                    status: nil,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400),
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                )
            ]
        )
    }
    .background(Color.livithColor(.black100))
}

#Preview("Empty") {
    SetlistTabView(concertID: 1, setlistList: [])
        .background(Color.livithColor(.black100))
}
