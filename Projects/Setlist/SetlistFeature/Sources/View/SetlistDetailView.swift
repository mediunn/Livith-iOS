//
//  SetlistDetailView.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import SetlistDomain

public struct SetlistDetailView: View {

    // MARK: - Property

    @StateObject private var store = SetlistStore()
    @Environment(\.dismiss) private var dismiss

    private let concertID: Int
    private let setlistID: Int
    private let onPlaySong: ((SetlistSong) -> Void)?
    private let onReportTapped: (() -> Void)?

    // MARK: - Initializer

    public init(
        concertID: Int,
        setlistID: Int,
        onPlaySong: ((SetlistSong) -> Void)? = nil,
        onReportTapped: (() -> Void)? = nil
    ) {
        self.concertID = concertID
        self.setlistID = setlistID
        self.onPlaySong = onPlaySong
        self.onReportTapped = onReportTapped
    }

    private var showErrorToast: Binding<Bool> {
        Binding(
            get: { store.state.fetchError != nil },
            set: { if !$0 { store.send(.onFetchErrorDismiss) } }
        )
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ZStack {
                Color.livithColor(.black100)
                    .ignoresSafeArea()

                if store.state.isLoading {
                    loadingView
                } else if let setlist = store.state.setlist {
                    contentView(setlist: setlist)
                } else if store.state.fetchError != nil {
                    emptyView
                }
            }
        }
        .background(Color.livithColor(.black100))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .livithToast(
            isPresented: showErrorToast,
            type: .failure,
            message: store.state.fetchError ?? ""
        )
        .onAppear {
            store.send(.onAppear(concertID: concertID, setlistID: setlistID))
        }
    }
}

// MARK: - Subviews

private extension SetlistDetailView {
    var navigationBar: some View {
        HStack(spacing: 4) {
            Button {
                dismiss()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 38, height: 38)
            }

            Text(store.state.setlist?.title ?? "")
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 66)
        .background(Color.livithColor(.black100))
    }

    var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(Color.livithColor(.white100))
    }

    var emptyView: some View {
        LivithEmptyView(text: "셋리스트가 없어요")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func contentView(setlist: Setlist) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                SetlistHeaderView(setlist: setlist)

                VStack(spacing: 16) {
                    SectionHeaderView(
                        firstLine: setlist.type.displayText,
                        onReportTapped: { onReportTapped?() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    songListView
                }
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
    }

    var songListView: some View {
        SetlistSongListCard(songs: store.state.songs, onPlaySong: onPlaySong)
    }
}

#Preview {
    NavigationStack {
        SetlistDetailView(concertID: 1, setlistID: 1)
    }
}
