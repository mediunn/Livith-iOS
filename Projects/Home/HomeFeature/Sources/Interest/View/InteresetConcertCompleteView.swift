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
    
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    Image.livithImage(.interestConcertComplete)
                        .resizable()
                        .scaledToFill()
                        .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
                        .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: isRotating)
                }
                
                VStack(spacing: 52) {
                    NotchedConcertPosterImage(url: concertPosterURL)
                        .frame(width: 132, height: 176)
                        .scaleEffect(isScaled ? 1.0 : 1.2)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isScaled)
                    
                    (Text("[\(concertTitle)]")
                        .foregroundStyle(.livithColor(.yellow30))
                     + Text("이\n관심 콘서트로 설정됐어요.")
                        .foregroundStyle(.livithColor(.white100)))
                    .notosans(.headSemibold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 80)
                .padding(.horizontal, 16)
            }
            
            LivithButton("확인", variant: .primary) {
                coordinator?.popToRoot()
            }
            .padding(.horizontal, 16)
        }
        .background(.livithColor(.black100))
        .onAppear {
            isRotating = true
            
            if !reduceMotion {
                isScaled = true
            }
        }
    }
}

#Preview {
    InteresetConcertCompleteView(
        concertPosterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!,
        concertTitle: "호시노 겐"
    )
}
