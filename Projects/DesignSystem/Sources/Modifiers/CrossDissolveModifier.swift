//
//  CrossDissolveModifier.swift
//  LivithDesignSystem
//
//  Created by Livith on 2026/01/16.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - CrossDissolve Modifier

private enum CrossDissolveConstants {
    static let animationDuration: Double = 0.25
    static let dimColor: String = "14171B"
    static let dimOpacity: Double = 0.9
}

/// UIKit의 `crossDissolve` 전환 효과처럼 fade in/out 애니메이션으로 오버레이를 표시하는 ViewModifier입니다.
/// `fullScreenCover`를 기반으로 하여 탭바 위에 표시됩니다.
public struct CrossDissolveModifier<OverlayContent: View>: ViewModifier {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let dismissOnTapOutside: Bool
    private let overlayContent: () -> OverlayContent
    
    @State private var internalPresented: Bool = false
    
    // MARK: - Initializer
    
    public init(
        isPresented: Binding<Bool>,
        dismissOnTapOutside: Bool,
        overlayContent: @escaping () -> OverlayContent
    ) {
        self._isPresented = isPresented
        self.dismissOnTapOutside = dismissOnTapOutside
        self.overlayContent = overlayContent
    }
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $internalPresented) {
                CrossDissolveContainerView(
                    isPresented: $isPresented,
                    dismissOnTapOutside: dismissOnTapOutside,
                    animationDuration: CrossDissolveConstants.animationDuration,
                    dimColor: CrossDissolveConstants.dimColor,
                    dimOpacity: CrossDissolveConstants.dimOpacity,
                    content: overlayContent
                )
                .presentationBackground(.clear)
            }
            .transaction { $0.disablesAnimations = true }
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    internalPresented = true
                }
            }
            .onChange(of: internalPresented) { _, newValue in
                if !newValue {
                    isPresented = false
                }
            }
    }
}

// MARK: - CrossDissolveContainerView

private struct CrossDissolveContainerView<Content: View>: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    let dismissOnTapOutside: Bool
    let animationDuration: Double
    let dimColor: String
    let dimOpacity: Double
    let content: () -> Content
    
    @State private var opacity: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(hex: dimColor, opacity: dimOpacity * opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    if dismissOnTapOutside {
                        dismissWithAnimation()
                    }
                }
            
            content()
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration)) {
                opacity = 1
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if !newValue {
                dismissWithAnimation()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            dismiss()
        }
    }
}

// MARK: - View Extension

public extension View {
    
    /// UIKit의 `crossDissolve` 전환 효과처럼 fade in/out 애니메이션으로 오버레이를 표시합니다.
    ///
    /// - Parameters:
    ///   - isPresented: 오버레이 표시 여부를 제어하는 바인딩
    ///   - dismissOnBackgroundTap: 배경 탭 시 dismiss 여부 (기본값: `false`)
    ///   - content: 표시할 오버레이 콘텐츠
    /// - Returns: CrossDissolve 효과가 적용된 뷰
    func crossDissolve<Content: View>(
        isPresented: Binding<Bool>,
        dismissOnTapOutside: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(CrossDissolveModifier(
            isPresented: isPresented,
            dismissOnTapOutside: dismissOnTapOutside,
            overlayContent: content
        ))
    }
}

// MARK: - Preview

#if DEBUG
private struct DemoModalView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("알림")
                .font(.headline)
                .foregroundStyle(Color.black)
            
            Text("이것은 커스텀 모달입니다.\n배경 동작을 확인해보세요.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(Color.gray)
            
            Button {
                isPresented = false
            } label: {
                Text("닫기")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 40)
    }
}

private struct DemoFullScreenView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                Text("풀스크린 뷰입니다")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Fade In/Out 애니메이션이 적용됩니다")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
    }
}

struct CrossDissolvePreviewView: View {
    @State private var isPresentedDismissable = false
    @State private var isPresentedNonDismissable = false
    @State private var isPresentedFullScreen = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Button("배경 탭으로 닫기 가능 모달") {
                        isPresentedDismissable = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("배경 탭으로 닫기 불가 모달") {
                        isPresentedNonDismissable = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("전체 화면 보기 (Fade In/Out)") {
                        isPresentedFullScreen = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Fake TabBar
            VStack(spacing: 0) {
                Divider()
                HStack {
                    ForEach(0..<4) { index in
                        VStack(spacing: 4) {
                            Image(systemName: index == 0 ? "house.fill" : "circle")
                                .font(.system(size: 24))
                            Text("Tab \(index + 1)")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(index == 0 ? Color.blue : Color.gray)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 34) // Safe Area
                .background(Color.white)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .crossDissolve(
            isPresented: $isPresentedDismissable,
            dismissOnTapOutside: true
        ) {
            DemoModalView(isPresented: $isPresentedDismissable)
        }
        .crossDissolve(isPresented: $isPresentedNonDismissable, dismissOnTapOutside: false) {
            DemoModalView(isPresented: $isPresentedNonDismissable)
        }
        .crossDissolve(isPresented: $isPresentedFullScreen, dismissOnTapOutside: false) {
            DemoFullScreenView(isPresented: $isPresentedFullScreen)
        }
    }
}

#Preview {
    CrossDissolvePreviewView()
}
#endif
