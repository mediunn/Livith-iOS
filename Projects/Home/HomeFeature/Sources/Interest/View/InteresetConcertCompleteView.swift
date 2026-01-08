//
//  InteresetConcertCompleteView.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit
import HomeDomain

struct InteresetConcertCompleteView: View {
    @State private var isRotating = false
    @State private var isScaled = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.homeCoordinator) var coordinator
    
    let concertPosterURL: URL?
    let concertTitle: String
    let prefetchedImage: UIImage?
    
    var body: some View {
        contentView
            .clipped()
            .background(.livithColor(.black100))
            .onAppear {
                isRotating = true
                
                if !reduceMotion {
                    isScaled = true
                }
            }
    }
}

private extension InteresetConcertCompleteView {
    var contentView: some View {
        ZStack(alignment: .bottom) {
            centerContentView
            
            confirmButton
        }
    }
    
    var centerContentView: some View {
        VStack(spacing: .zero) {
            Spacer()
            posterImageView
            titleTextView
            Spacer()
        }
    }
    
    var posterImageView: some View {
        NotchedConcertPosterImageView(url: concertPosterURL, image: prefetchedImage)
            .frame(width: 132, height: 176)
            .scaleEffect(isScaled ? 1.0 : 1.3)
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isScaled)
            .background {
                backgroundImageView
            }
    }
    
    var titleTextView: some View {
        (Text("[\(concertTitle)]")
            .foregroundStyle(.livithColor(.yellow30))
         + Text("이\n관심 콘서트로 설정됐어요.")
            .foregroundStyle(.livithColor(.white100)))
        .notosans(.headSemibold)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
        .padding(.top, 52)
    }
    
    var confirmButton: some View {
        ZStack {
            LivithButton("확인", variant: .primary) {
                coordinator?.popToRoot()
            }
            .padding(.horizontal, 16)
            .padding(.top, 60)
        }
        .background(.livithColor(.black100))
    }
    
    var backgroundImageView: some View {
        Image.livithImage(.interestConcertComplete)
            .resizable()
            .scaledToFill()
            .scaleEffect(6.0)
            .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
            .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: isRotating)
    }
}

#Preview {
    InteresetConcertCompleteView(
        concertPosterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!,
        concertTitle: "Veniam dolor et irure quis velit dolor et mollit quis anim do ",
        prefetchedImage: nil
    )
}
