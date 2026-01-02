//
//  SongLyricsView.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import YouTubePlayerKit

import DSKit
import SongDomain

public struct SongLyricsView: View {

    // MARK: - Property

    @StateObject private var store = SongLyricsStore()
    @Environment(\.dismiss) private var dismiss

    private let songID: Int
    private let setlistID: Int?
    private let songTitle: String
    private let onReportTapped: (() -> Void)?

    // MARK: - Initializer

    public init(
        songID: Int,
        setlistID: Int? = nil,
        songTitle: String,
        onReportTapped: (() -> Void)? = nil
    ) {
        self.songID = songID
        self.setlistID = setlistID
        self.songTitle = songTitle
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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.livithColor(.black100)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    navigationBar
                    contentView(geometry: geometry)
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
            store.send(.onAppear(songID: songID, setlistID: setlistID, songTitle: songTitle))
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

            Text(store.state.songTitle)
                .notosans(.body1Semibold)
                .foregroundStyle(Color.livithColor(.white100))
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            Button {
                onReportTapped?()
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
    }

    func contentView(geometry: GeometryProxy) -> some View {
        let videoHeight = geometry.size.width * 9 / 16
        let toggleHeight: CGFloat = 70

        return ZStack(alignment: .top) {
            VStack(spacing: 0) {
                youtubePlayerView
                    .frame(height: videoHeight)

                toggleButtonsSection
                    .frame(height: toggleHeight)
            }

            LyricsBottomSheetView(
                store: store,
                screenHeight: geometry.size.height,
                videoHeight: videoHeight,
                toggleHeight: toggleHeight
            )
        }
    }

    var toggleButtonsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                LyricsToggleButton(
                    title: "원어",
                    isOn: store.state.showOriginal,
                    activeBackgroundColor: Color.livithColor(.original)
                ) {
                    store.send(.toggleOriginal)
                }

                LyricsToggleButton(
                    title: "발음",
                    isOn: store.state.showPronunciation,
                    activeBackgroundColor: Color.livithColor(.white100)
                ) {
                    store.send(.togglePronunciation)
                }

                LyricsToggleButton(
                    title: "해석",
                    isOn: store.state.showTranslation,
                    activeBackgroundColor: Color.livithColor(.translation),
                    activeTextColor: Color.livithColor(.black100)
                ) {
                    store.send(.toggleTranslation)
                }

                if store.state.hasFanchant {
                    LyricsToggleButton(
                        title: "응원법",
                        isOn: store.state.showFanchant,
                        activeBackgroundColor: Color.livithColor(.yellow30),
                        activeTextColor: Color.livithColor(.black100)
                    ) {
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

// MARK: - YouTube Player View

private struct YouTubePlayerView: View {
    @StateObject private var player: YouTubePlayer
    @State private var isLoading = true
    @State private var hasError = false

    init(youtubeID: String) {
        let configuration = YouTubePlayer.Configuration(
            autoPlay: true,
            showControls: true,
            useModestBranding: true,
            playInline: true,
            showRelatedVideos: false
        )
        _player = StateObject(wrappedValue: YouTubePlayer(
            source: .video(id: youtubeID),
            configuration: configuration
        ))
    }

    var body: some View {
        ZStack {
            if hasError {
                videoErrorView
            } else {
                YouTubePlayerKit.YouTubePlayerView(player)
                    .onReceive(player.statePublisher) { state in
                        switch state {
                        case .ready:
                            isLoading = false
                        case .error:
                            hasError = true
                            isLoading = false
                        default:
                            break
                        }
                    }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.livithColor(.white100))
                }
            }
        }
    }

    var videoErrorView: some View {
        ZStack {
            Color.livithColor(.black90)
            Image.livithImage(.livithLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .opacity(0.3)
        }
    }
}
