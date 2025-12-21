//
//  WelcomeSheetView.swift
//  Livith-iOS
//
//  Created by 김진웅 on 12/21/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

import DSKit

struct WelcomeSheetView: View {
    let nickname: String
    var onDismiss: (() -> Void)?
    
    @State private var isVisible: Bool = true

    var body: some View {
        ZStack {
            Color.livithColor(.black100)
                .opacity(0.9)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                Image.livithImage(.welcome)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                
                Text("\(nickname)님,\n라이빗에 어서오세요!")
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
                
                Text("라이빗과 즐거운 내한 공연을 준비해 볼까요?")
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.top, 8)
                
                Button {
                    Task { @MainActor in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }

                        try? await Task.sleep(for: .seconds(0.4))
                        onDismiss?()
                    }
                } label: {
                    Text("시작하기")
                        .notosans(.body3Medium)
                        .foregroundColor(.livithColor(.black100))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.livithColor(.yellow30))
                        .cornerRadius(4)
                }
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 16)
            }
            .frame(width: 328)
            .background(Color.livithColor(.black90))
            .cornerRadius(12)
            .overlay {
                Image.livithImage(.polygon)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.4))
                withAnimation(.easeInOut(duration: 0.3)) {
                    isVisible = true
                }
            }
        }
    }
}

#Preview {
    WelcomeSheetView(nickname: "유지미")
}
