//
//  SongLyricsView.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

import Domain
import LivithDesignSystem

public struct SongLyricsView: View {

    // MARK: - Property

    @StateObject private var store = SongLyricsStore()
    @Environment(\.dismiss) private var dismiss
    @State private var sheetPosition: LyricsBottomSheetView.SheetPosition = .middle
    @State private var warningMessage: String?
    @State private var errorMessage: String?
    @State private var warningDismissTask: Task<Void, Never>?

    private let songID: Int
    private let setlistID: Int?
    private let songTitle: String
    private let onReportTapped: () -> Void

    // MARK: - Initializer

    public init(
        songID: Int,
        setlistID: Int? = nil,
        songTitle: String,
        onReportTapped: @escaping () -> Void = {}
    ) {
        self.songID = songID
        self.setlistID = setlistID
        self.songTitle = songTitle
        self.onReportTapped = onReportTapped
    }

    private var showErrorToast: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private var overlayOpacity: Double {
        switch sheetPosition {
        case .bottom, .middle:
            return 0
        case .top:
            return 0.9
        }
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.livithColor(.black100)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    navigationBar
                    contentView(geometry: geometry)
                }

                if let message = warningMessage {
                    ToggleWarningPopup(message: message)
                }
            }
        }
        .background(Color.livithColor(.black100))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .livithToast(
            isPresented: showErrorToast,
            type: .failure,
            message: errorMessage ?? ""
        )
        .onAppear {
            store.send(.onAppear(songID: songID, setlistID: setlistID, songTitle: songTitle))
        }
        .onChange(of: store.state.fetchError) { _, newValue in
            if let error = newValue {
                errorMessage = error
            }
        }
        .onChange(of: store.state.toggleWarningMessage) { _, newValue in
            if let message = newValue {
                warningMessage = message
                warningDismissTask?.cancel()
                warningDismissTask = Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.5))
                    guard !Task.isCancelled else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        warningMessage = nil
                    }
                    try? await Task.sleep(for: .seconds(0.3))
                    store.send(.clearToggleWarning)
                }
            }
        }
        .onDisappear {
            warningDismissTask?.cancel()
        }
    }
}

// MARK: - Subviews

private extension SongLyricsView {
    var navigationBar: some View {
        HStack(spacing: 4) {
            Button {
                dismiss()
            } label: {
                Image.livithIcon(.backLineDefault)
                    .resizable()
                    .frame(width: 38, height: 38)
            }

            MarqueeText(
                text: store.state.songTitle,
                font: .body1Semibold,
                textColor: Color.livithColor(.white100)
            )

            Spacer()
                .frame(width: 8)

            Button {
                onReportTapped()
            } label: {
                Text("정보 제보")
                    .notosans(.caption1Semibold)
                    .foregroundStyle(Color.livithColor(.black50))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.livithColor(.black80), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 66)
        .background(Color.livithColor(.black100))
        .overlay(
            Color.livithColor(.black100)
                .opacity(overlayOpacity)
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 0.3), value: sheetPosition)
        )
    }

    func contentView(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let screenHeight = geometry.size.height
        let videoHeight = screenWidth > 0 ? screenWidth * 9 / 16 : 200
        let toggleHeight: CGFloat = 70

        return ZStack(alignment: .top) {
            VStack(spacing: 0) {
                youtubePlayerView
                    .frame(height: videoHeight)

                if store.state.hasLyrics {
                    toggleButtonsSection
                        .frame(height: toggleHeight)
                } else {
                    lyricsEmptyView
                }
            }

            if store.state.hasLyrics, screenHeight > 0, screenWidth > 0 {
                Color.livithColor(.black100)
                    .opacity(overlayOpacity)
                    .allowsHitTesting(false)
                    .animation(.easeInOut(duration: 0.3), value: sheetPosition)

                LyricsBottomSheetView(
                    store: store,
                    screenHeight: screenHeight,
                    videoHeight: videoHeight,
                    toggleHeight: toggleHeight,
                    currentPosition: $sheetPosition
                )
            }
        }
    }

    var lyricsEmptyView: some View {
        VStack {
            Spacer()
            LivithEmptyView(text: "가사 정보가 없어요")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.livithColor(.black100))
    }

    var toggleButtonsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                LivithToggleButton("원어", isOn: store.state.showOriginal, style: .original) {
                    store.send(.toggleOriginal)
                }

                LivithToggleButton("발음", isOn: store.state.showPronunciation, style: .pronunciation) {
                    store.send(.togglePronunciation)
                }

                LivithToggleButton("해석", isOn: store.state.showTranslation, style: .translation) {
                    store.send(.toggleTranslation)
                }

                if store.state.hasFanchant {
                    LivithToggleButton("응원법", isOn: store.state.showFanchant, style: .fanchant) {
                        store.send(.toggleFanchant)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.livithColor(.black100))
    }

    @ViewBuilder
    var youtubePlayerView: some View {
        if store.state.hasYouTubeVideo, let youtubeID = store.state.lyrics?.youtubeID {
            YouTubePlayerView(youtubeID: youtubeID)
        } else {
            Image.livithImage(.youtubeEmpty)
                .resizable()
                .scaledToFill()
        }
    }

}
