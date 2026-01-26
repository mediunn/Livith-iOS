//
//  FilterBottomSheetView.swift
//  Search
//
//  Created by Youjin Lee on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

public struct FilterBottomSheetView: View {
    @Binding var selectedGenreList: [ConcertGenre]
    @Binding var selectedStatusList: [ConcertStatus]
    @Binding var showFilter: Bool

    @State private var tempGenreList: [ConcertGenre] = []
    @State private var tempStatusList: [ConcertStatus] = []

    public init(
        selectedGenreList: Binding<[ConcertGenre]>,
        selectedStatusList: Binding<[ConcertStatus]>,
        showFilter: Binding<Bool>
    ) {
        self._selectedGenreList = selectedGenreList
        self._selectedStatusList = selectedStatusList
        self._showFilter = showFilter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("장르")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
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
        .onChange(of: showFilter) { _, isShowing in
            if isShowing {
                tempGenreList = selectedGenreList
                tempStatusList = selectedStatusList
            }
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
                LivithChipButton(
                    "전체",
                    style: tempGenreList.isEmpty ? .selected : .outline
                ) {
                    tempGenreList = []
                }

                ForEach(selectableGenres.prefix(3), id: \.self) { genre in
                    LivithChipButton(
                        genre.genreText,
                        style: tempGenreList.contains(genre) ? .selected : .outline
                    ) {
                        toggleGenre(genre)
                    }
                }
            }

            HStack(alignment: .center, spacing: 10) {
                ForEach(selectableGenres.suffix(3), id: \.self) { genre in
                    LivithChipButton(
                        genre.genreText,
                        style: tempGenreList.contains(genre) ? .selected : .outline
                    ) {
                        toggleGenre(genre)
                    }
                }
            }
        }
    }

    var selectableStatusList: [ConcertStatus] {
        ConcertStatus.allCases.filter { $0 != .past }
    }

    var statusOptions: some View {
        HStack(alignment: .center, spacing: 4) {
            LivithChipButton(
                "전체",
                style: tempStatusList.isEmpty ? .selected : .outline
            ) {
                tempStatusList = []
            }

            ForEach(selectableStatusList, id: \.self) { status in
                LivithChipButton(
                    status.filterText,
                    style: tempStatusList.contains(status) ? .selected : .outline
                ) {
                    toggleStatus(status)
                }
            }
        }
    }
    
    var setupButtons: some View {
        HStack(spacing: 12) {
            LivithButton("초기화", variant: .primary) {
                tempGenreList = []
                tempStatusList = []
            }
            .disabled(!hasSelection)

            LivithButton("설정하기", variant: .primary) {
                selectedGenreList = tempGenreList
                selectedStatusList = tempStatusList
                showFilter = false
            }
        }
    }

    func toggleGenre(_ genre: ConcertGenre) {
        if tempGenreList.contains(genre) {
            tempGenreList.removeAll { $0 == genre }
        } else {
            tempGenreList.append(genre)
        }
    }

    func toggleStatus(_ status: ConcertStatus) {
        if tempStatusList.contains(status) {
            tempStatusList.removeAll { $0 == status }
        } else {
            tempStatusList.append(status)
        }
    }
}
