//
//  SetlistDetailView.swift
//  SetlistFeature
//
//  Created by Youjin Lee on 12/30/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import Amplitude
import Domain
import LivithDesignSystem

public struct SetlistDetailView: View {

    // MARK: - Property

    private static let reportFormURL = URL(string: "https://forms.gle/aMj5C4LhDcMzueWz5")!

    @StateObject private var store = SetlistStore()
    @Environment(\.dismiss) private var dismiss

    private let concertID: Int
    private let setlistID: Int
    private let onPlaySong: ((SetlistSong) -> Void)?

    @State private var isReportSheetPresented: Bool = false

    // MARK: - Initializer

    public init(
        concertID: Int,
        setlistID: Int,
        onPlaySong: ((SetlistSong) -> Void)? = nil
    ) {
        self.concertID = concertID
        self.setlistID = setlistID
        self.onPlaySong = onPlaySong
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
            LivithNavigationView(type: .back(title: store.state.setlist?.title ?? "", onBack: { dismiss() }))

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
        .sheet(isPresented: $isReportSheetPresented) {
            SafariView(url: Self.reportFormURL)
        }
        .onAppear {
            store.send(.onAppear(concertID: concertID, setlistID: setlistID))
        }
    }
}

// MARK: - Subviews

private extension SetlistDetailView {
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
                        onReportTapped: {
                            AmplitudeService.shared.trackEvent(tag: .click(.reportSetlist))
                            isReportSheetPresented = true
                        }
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
