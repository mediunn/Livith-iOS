//
//  YouTubePlayerView.swift
//  SongFeature
//
//  Created by Youjin Lee on 1/2/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import YouTubePlayerKit

import LivithDesignSystem

struct YouTubePlayerView: View {

    // MARK: - Property

    private let youtubeID: String

    @State private var player: YouTubePlayer?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var isViewActive = false

    // MARK: - Initializer

    init(youtubeID: String) {
        self.youtubeID = youtubeID
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if hasError {
                videoErrorView
            } else if let player, isViewActive {
                YouTubePlayerKit.YouTubePlayerView(player)
                    .onReceive(player.statePublisher) { state in
                        guard isViewActive else { return }
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
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.livithColor(.white100))
            }
        }
        .onAppear {
            isViewActive = true
            if player == nil {
                player = createPlayer()
            }
        }
        .onDisappear {
            isViewActive = false
        }
    }
}

// MARK: - Subviews

private extension YouTubePlayerView {
    var videoErrorView: some View {
        Image.livithImage(.youtubeEmpty)
            .resizable()
            .scaledToFill()
    }
}

// MARK: - Private Methods

private extension YouTubePlayerView {
    func createPlayer() -> YouTubePlayer {
        let configuration = YouTubePlayer.Configuration(
            autoPlay: true,
            showControls: true,
            useModestBranding: true,
            playInline: true,
            showRelatedVideos: false
        )
        return YouTubePlayer(
            source: .video(id: youtubeID),
            configuration: configuration
        )
    }
}
