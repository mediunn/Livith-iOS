//
//  SetlistTabView.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import ConcertDomain
import DSKit

struct SetlistTabView: View {

    // MARK: - Property

    @Environment(\.concertCoordinator) private var coordinator

    let setlistList: [ConcertSetlist]

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

    func setlistCard(for setlist: ConcertSetlist) -> some View {
        ThumbnailCard(
            imageURL: setlist.imageURL.flatMap { URL(string: $0) },
            title: setlist.title,
            subtitle: formatDate(setlist),
            flexible: true,
            titleLineLimit: 2
        )
        .overlay(alignment: .topLeading) {
            if setlist.status != .none {
                SetlistTagView(type: setlist.status)
                    .padding(10)
            }
        }
    }

    func formatDate(_ setlist: ConcertSetlist) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        let startDateString = formatter.string(from: setlist.startDate)

        if setlist.startDate == setlist.endDate {
            return startDateString
        }

        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: setlist.startDate)
        let endYear = calendar.component(.year, from: setlist.endDate)

        if startYear == endYear {
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "MM.dd"
            let endShortString = shortFormatter.string(from: setlist.endDate)
            return "\(startDateString)~\(endShortString)"
        } else {
            let endDateString = formatter.string(from: setlist.endDate)
            return "\(startDateString)~\(endDateString)"
        }
    }
}

#Preview {
    ScrollView {
        SetlistTabView(
            setlistList: [
                ConcertSetlist(
                    id: 1,
                    title: "Gen Hoshino presents MAD HOPE 202",
                    imageURL: nil,
                    type: .upcoming,
                    startDate: Date(),
                    endDate: Date(),
                    status: .expected,
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                ),
                ConcertSetlist(
                    id: 2,
                    title: "World Tour [ LIVE FULL E...",
                    imageURL: nil,
                    type: .upcoming,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400),
                    status: .recent,
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                ),
                ConcertSetlist(
                    id: 3,
                    title: "World Tour [ LIVE FULL E...",
                    imageURL: nil,
                    type: .upcoming,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400),
                    status: .recent,
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                ),
                ConcertSetlist(
                    id: 4,
                    title: "World Tour [ LIVE FULL E...",
                    imageURL: nil,
                    type: .upcoming,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400),
                    status: .none,
                    venue: "올림픽공원 올림픽홀",
                    artist: "호시노 겐"
                )
            ]
        )
    }
    .background(Color.livithColor(.black100))
}

#Preview("Empty") {
    SetlistTabView(setlistList: [])
        .background(Color.livithColor(.black100))
}
