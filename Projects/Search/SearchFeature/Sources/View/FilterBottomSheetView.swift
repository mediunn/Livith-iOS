//
//  FilterBottomSheetView.swift
//  Search
//
//  Created by Youjin Lee on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import SearchDomain
import DesignSystem

public struct FilterBottomSheetView: View {
    @Binding var selectedGenreList: [SearchDomain.ConcertGenre]
    @Binding var selectedStatusList: [SearchDomain.ConcertStatus]
    @Binding var showFilter: Bool

    @State private var tempGenreList: [SearchDomain.ConcertGenre] = []
    @State private var tempStatusList: [SearchDomain.ConcertStatus] = []

    public init(
        selectedGenreList: Binding<[SearchDomain.ConcertGenre]>,
        selectedStatusList: Binding<[SearchDomain.ConcertStatus]>,
        showFilter: Binding<Bool>
    ) {
        self._selectedGenreList = selectedGenreList
        self._selectedStatusList = selectedStatusList
        self._showFilter = showFilter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.livithColor(.black80))
                .frame(height: 6)
                .padding(.top, 10)
                .padding(.horizontal, 150)
                .padding(.bottom, 8)
                .cornerRadius(8)

            Text("장르")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.horizontal, 16)

            genreOptions
                .padding(.horizontal, 16)
                .padding(.top, 20)

            Rectangle()
                .fill(Color.livithColor(.black80))
                .frame(height: 1)
                .padding(.horizontal, 16)
                .padding(.vertical, 30)

            Text("기간")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.horizontal, 16)

            statusOptions
                .padding(.horizontal, 16)
                .padding(.top, 20)

            setupButtons
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
        .animation(nil, value: showFilter)
        .onAppear {
            tempGenreList = selectedGenreList
            tempStatusList = selectedStatusList
        }
    }
}

private extension FilterBottomSheetView {
    var hasSelection: Bool {
        !tempGenreList.isEmpty || !tempStatusList.isEmpty
    }

    var selectableGenres: [ConcertGenre] {
        ConcertGenre.allCases.filter { $0 != .all }
    }

    var genreOptions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                FilterOptionButton(
                    title: "전체",
                    isSelected: tempGenreList.isEmpty,
                    action: { tempGenreList = [] }
                )

                ForEach(selectableGenres.prefix(3), id: \.self) { genre in
                    FilterOptionButton(
                        title: genre.genreText,
                        isSelected: tempGenreList.contains(genre),
                        action: { toggleGenre(genre) }
                    )
                }
            }

            HStack(alignment: .center, spacing: 10) {
                ForEach(selectableGenres.suffix(3), id: \.self) { genre in
                    FilterOptionButton(
                        title: genre.genreText,
                        isSelected: tempGenreList.contains(genre),
                        action: { toggleGenre(genre) }
                    )
                }
            }
        }
    }

    var statusOptions: some View {
        HStack(alignment: .center, spacing: 4) {
            FilterOptionButton(
                title: "전체",
                isSelected: tempStatusList.isEmpty,
                action: { tempStatusList = [] }
            )

            ForEach(ConcertStatus.allCases, id: \.self) { status in
                FilterOptionButton(
                    title: status.filterText,
                    isSelected: tempStatusList.contains(status),
                    action: { toggleStatus(status) }
                )
            }
        }
    }
    
    var setupButtons: some View {
        HStack(spacing: 12) {
            Button {
                tempGenreList = []
                tempStatusList = []
            } label: {
                Text("초기화")
                    .notosans(.body3Semibold)
                    .foregroundStyle(hasSelection ? Color.livithColor(.white100) : Color.livithColor(.black50))
                    .frame(maxWidth: .infinity)
                    .frame(height: 51)
                    .background(hasSelection ? Color.livithColor(.black50) : Color.livithColor(.black80))
                    .cornerRadius(6)
            }
            .disabled(!hasSelection)

            Button {
                selectedGenreList = tempGenreList
                selectedStatusList = tempStatusList
                showFilter = false
            } label: {
                Text("설정하기")
                    .notosans(.body3Semibold)
                    .foregroundStyle(Color.livithColor(.black100))
                    .frame(maxWidth: .infinity)
                    .frame(height: 51)
                    .background(Color.livithColor(.yellow30))
                    .cornerRadius(6)
            }
        }
    }

    func toggleGenre(_ genre: SearchDomain.ConcertGenre) {
        if tempGenreList.contains(genre) {
            tempGenreList.removeAll { $0 == genre }
        } else {
            tempGenreList.append(genre)
        }
    }

    func toggleStatus(_ status: SearchDomain.ConcertStatus) {
        if tempStatusList.contains(status) {
            tempStatusList.removeAll { $0 == status }
        } else {
            tempStatusList.append(status)
        }
    }
}
