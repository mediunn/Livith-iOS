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
        contentView
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
        VStack(spacing: .zero) {
            VStack(spacing: .zero) {
                Spacer()
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
                .padding(.top, 52)
                
                Spacer()
            }
            .background(
                imageView
                    .padding(.bottom, 60)
            )
            
            Button {
                coordinator?.popToRoot()
            } label: {
                Text("확인")
                    .notosans(.body3Semibold)
                    .foregroundColor(.livithColor(.black100))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(.livithColor(.yellow30))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
    }
    
    var imageView: some View {
        Image.livithImage(.interestConcertComplete)
            .resizable()
            .scaledToFill()
            .rotationEffect(.degrees(isRotating ? 360 : 0), anchor: .center)
            .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: isRotating)
    }
}

#Preview {
    InteresetConcertCompleteView(
        concertPosterURL: URL(string: "https://kopis.or.kr/upload/pfmPoster/PF_PF278958_251113_113650.jpg")!,
        concertTitle: "Veniam dolor et irure quis velit dolor et mollit quis anim do incididunt mollit ullamco amet esse in"
    )
}
