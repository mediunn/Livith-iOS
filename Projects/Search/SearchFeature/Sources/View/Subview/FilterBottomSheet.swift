//
//  FilterBottomSheet.swift
//  Search
//
//  Created by Youjin Lee on 11/5/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import SearchDomain
import DesignSystem

public struct FilterBottomSheet: View {
    @Binding var selectedGenreList: [SearchDomain.ConcertGenre]
    @Binding var selectedStatusList: [SearchDomain.ConcertStatus]
    @Binding var showFilter: Bool

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
            Text("장르")
                .notosans(.body2Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .padding(.top, 24)
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

            HStack(spacing: 12) {
                
                Button {
                    selectedGenreList = []
                    selectedStatusList = []
                } label: {
                    Text("초기화")
                        .notosans(.body2Semibold)
                        .foregroundStyle(hasSelection ? Color.livithColor(.black100) : Color.livithColor(.black50))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(hasSelection ? Color.livithColor(.yellow30) : Color.livithColor(.black80))
                        .cornerRadius(12)
                }
                .disabled(!hasSelection)

                Button {
                    showFilter = false
                } label: {
                    Text("설정하기")
                        .notosans(.body2Semibold)
                        .foregroundStyle(hasSelection ? Color.livithColor(.black100) : Color.livithColor(.black50))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(hasSelection ? Color.livithColor(.yellow30) : Color.livithColor(.black80))
                        .cornerRadius(12)
                }
                .disabled(!hasSelection)
            }
            .padding(.top, 24)
            .padding(.horizontal, 16)
        }
        .presentationDetents([.height(368)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.livithColor(.black90))
        .presentationCornerRadius(16)
        
    }
}

private extension FilterBottomSheet {
    var hasSelection: Bool {
        !selectedGenreList.isEmpty || !selectedStatusList.isEmpty
    }

    var genreOptions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                FilterOptionButton(
                    title: "전체",
                    isSelected: selectedGenreList.isEmpty,
                    action: { selectedGenreList = [] }
                )

                FilterOptionButton(
                    title: "J-POP",
                    isSelected: selectedGenreList.contains(.jpop),
                    action: { toggleGenre(.jpop) }
                )

                FilterOptionButton(
                    title: "락/메탈",
                    isSelected: selectedGenreList.contains(.rockMetal),
                    action: { toggleGenre(.rockMetal) }
                )

                FilterOptionButton(
                    title: "랩/힙합",
                    isSelected: selectedGenreList.contains(.rapHiphop),
                    action: { toggleGenre(.rapHiphop) }
                )
            }

            HStack(alignment: .center, spacing: 10) {
                FilterOptionButton(
                    title: "클래식/재즈",
                    isSelected: selectedGenreList.contains(.classicJazz),
                    action: { toggleGenre(.classicJazz) }
                )

                FilterOptionButton(
                    title: "어쿠스틱",
                    isSelected: selectedGenreList.contains(.acoustic),
                    action: { toggleGenre(.acoustic) }
                )

                FilterOptionButton(
                    title: "일렉트로닉",
                    isSelected: selectedGenreList.contains(.electronic),
                    action: { toggleGenre(.electronic) }
                )
            }
        }
    }

    var statusOptions: some View {
        HStack(alignment: .center, spacing: 10) {
            FilterOptionButton(
                title: "전체",
                isSelected: selectedStatusList.isEmpty,
                action: { selectedStatusList = [] }
            )

            FilterOptionButton(
                title: "진행중",
                isSelected: selectedStatusList.contains(.ongoing),
                action: { toggleStatus(.ongoing) }
            )

            FilterOptionButton(
                title: "진행예정",
                isSelected: selectedStatusList.contains(.upcoming),
                action: { toggleStatus(.upcoming) }
            )

            FilterOptionButton(
                title: "진행완료",
                isSelected: selectedStatusList.contains(.completed),
                action: { toggleStatus(.completed) }
            )
        }
    }

    func toggleGenre(_ genre: SearchDomain.ConcertGenre) {
        if selectedGenreList.contains(genre) {
            selectedGenreList.removeAll { $0 == genre }
        } else {
            selectedGenreList.append(genre)
        }
    }

    func toggleStatus(_ status: SearchDomain.ConcertStatus) {
        if selectedStatusList.contains(status) {
            selectedStatusList.removeAll { $0 == status }
        } else {
            selectedStatusList.append(status)
        }
    }
}
