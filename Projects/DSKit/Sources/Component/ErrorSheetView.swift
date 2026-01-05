//
//  ErrorSheetView.swift
//  DesignSystem
//
//  Created by Youjin Lee on 11/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

public struct ErrorSheetView: View {
    public typealias ConfirmAction = () -> ()
    
    private let title: String
    private let message: String
    private let confirmTitle: String
    private let onConfirm: ConfirmAction?
    
    @State private var isVisible: Bool = false
    
    public init(
        title: String,
        message: String,
        confirmTitle: String = "확인",
        onConfirm: ConfirmAction? = nil
    ) {
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.onConfirm = onConfirm
    }
    
    public var body: some View {
        ZStack {
            Color.livithColor(.black100).opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Image.livithIcon(.cautionTriangleBig)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 16)
                
                Text(title)
                    .notosans(.body1Semibold)
                    .foregroundStyle(Color.livithColor(.white100))
                    .padding(.top, 4)
                
                Text(message)
                    .notosans(.body4Regular)
                    .foregroundStyle(Color.livithColor(.black30))
                    .padding(.top, 4)
                
                Button {
                    Task { @MainActor in
                        withAnimation(.easeOut(duration: 0.3)) {
                            isVisible = false
                        }
                        
                        try? await Task.sleep(for: .seconds(0.4))
                        
                        if let onConfirm {
                            onConfirm()
                        }
                    }
                } label: {
                    Text(confirmTitle)
                        .notosans(.body3Semibold)
                        .foregroundColor(.livithColor(.black100))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.livithColor(.translation))
                        .cornerRadius(4)
                }
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 16)
            }
            .frame(width: 328, height: 200)
            .background(Color.livithColor(.black90))
            .cornerRadius(12)
        }
        .opacity(isVisible ? 1 : 0)
        .presentationBackground(.clear)
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.4))
                withAnimation(.easeOut(duration: 0.3)) {
                    isVisible = true
                }
            }
        }
    }
}

#Preview {
    ErrorSheetView(
        title: "탈퇴 후 7일이 지나지 않았어요",
        message: "7일이 지난 후 다시 시도해주세요"
    ) {
        print("버튼이 눌렸다.")
    }
}
