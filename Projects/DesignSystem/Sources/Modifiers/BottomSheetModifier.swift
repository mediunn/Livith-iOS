//
//  BottomSheetModifier.swift
//  LivithDesignSystem
//
//  Created by Livith on 2026/01/24.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Handle Style

public enum HandleStyle {
    case dark
    case light
    
    var color: Color {
        switch self {
        case .dark:
            return Color.livithColor(.black80)
        case .light:
            return Color.livithColor(.white100)
        }
    }
    
    var width: CGFloat {
        switch self {
        case .dark:
            return 60
        case .light:
            return 132
        }
    }
}

/// 하단에서 올라오는 BottomSheet를 구현하는 ViewModifier입니다.
/// `fullScreenCover`를 기반으로 하여 콘텐츠를 상단만 둥글게 처리하고,
/// 슬라이드 애니메이션으로 표시/숨김 처리합니다.
public struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let dismissOnTapOutside: Bool
    private let contentBackground: Color
    private let handleStyle: HandleStyle
    private let sheetContent: () -> SheetContent
    
    @State private var internalPresented: Bool = false
    
    // MARK: - Initializer
    
    public init(
        isPresented: Binding<Bool>,
        dismissOnTapOutside: Bool,
        contentBackground: Color,
        handleStyle: HandleStyle,
        sheetContent: @escaping () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.dismissOnTapOutside = dismissOnTapOutside
        self.contentBackground = contentBackground
        self.handleStyle = handleStyle
        self.sheetContent = sheetContent
    }
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $internalPresented) {
                BottomSheetContainerView(
                    isPresented: $isPresented,
                    dismissOnTapOutside: dismissOnTapOutside,
                    handleStyle: handleStyle,
                    contentBackground: contentBackground,
                    content: sheetContent
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

// MARK: - BottomSheetContainerView

private struct BottomSheetContainerView<Content: View>: View {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    let dismissOnTapOutside: Bool
    let handleStyle: HandleStyle
    let contentBackground: Color
    let content: () -> Content
    
    @State private var sheetOffset: CGFloat = UIScreen.main.bounds.height
    @State private var dimOpacityValue: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "14171B", opacity: 0.9 * dimOpacityValue)
                .ignoresSafeArea()
                .onTapGesture {
                    if dismissOnTapOutside {
                        dismissWithAnimation()
                    }
                }
            
            VStack(spacing: 0) {
                handleBar
                    .padding(.top, 10)
                
                content()
                    .frame(maxWidth: .infinity)
            }
            .background(contentBackground)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    topTrailingRadius: 20
                )
            )
            .offset(y: sheetOffset)
            .padding(.horizontal, 4)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            sheetOffset = UIScreen.main.bounds.height
            dimOpacityValue = 0
            withAnimation(.easeInOut(duration: 0.3)) {
                sheetOffset = 0
                dimOpacityValue = 1
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if !newValue {
                dismissWithAnimation()
            }
        }
    }
    
    var handleBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(handleStyle.color)
            .frame(width: handleStyle.width, height: 6)
    }
    
    // MARK: - Private Methods
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            sheetOffset = UIScreen.main.bounds.height
            dimOpacityValue = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

// MARK: - View Extension

public extension View {
    
    /// 하단에서 올라오는 BottomSheet를 표시합니다.
    ///
    /// - Parameters:
    ///   - isPresented: 바텀시트 표시 여부를 제어하는 바인딩
    ///   - dismissOnTapOutside: 배경 탭 시 dismiss 여부 (기본값: `true`)
    ///   - contentBackground: 바텀시트 배경색 (기본값: `black90`)
    ///   - handleStyle: 상단 핸들 스타일 (기본값: `.dark`)
    ///   - content: 표시할 바텀시트 콘텐츠
    /// - Returns: BottomSheet 효과가 적용된 뷰
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        dismissOnTapOutside: Bool = true,
        contentBackground: Color = .livithColor(.black90),
        handleStyle: HandleStyle = .dark,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(BottomSheetModifier(
            isPresented: isPresented,
            dismissOnTapOutside: dismissOnTapOutside,
            contentBackground: contentBackground,
            handleStyle: handleStyle,
            sheetContent: content
        ))
    }
}

// MARK: - Preview

#if DEBUG
private struct DemoBottomSheetView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("바텀시트")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.black)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(Color.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            VStack(spacing: 12) {
                Text("배경을 탭하면 닫힙니다")
                    .font(.body)
                    .foregroundStyle(Color.gray)
                
                Text("또는 닫기 버튼을 누르세요")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            
            Divider()
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<5) { index in
                        VStack(spacing: 8) {
                            Text("아이템 \(index + 1)")
                                .font(.headline)
                                .foregroundStyle(Color.black)
                            
                            Text("바텀시트의 콘텐츠입니다")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 24)
            }
            
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
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

private struct DemoSmallBottomSheetView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("작은 바텀시트")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.black)
            
            Text("크기와 관계없이 정상 작동합니다")
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
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding(24)
    }
}

struct BottomSheetPreviewView: View {
    @State private var isPresented = false
    @State private var isSmallPresented = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    Button("큰 바텀시트 열기") {
                        isPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("작은 바텀시트 열기") {
                        isSmallPresented = true
                    }
                    .buttonStyle(.bordered)
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
        .bottomSheet(isPresented: $isPresented, dismissOnTapOutside: true) {
            DemoBottomSheetView(isPresented: $isPresented)
        }
        .bottomSheet(isPresented: $isSmallPresented, dismissOnTapOutside: true) {
            DemoSmallBottomSheetView(isPresented: $isSmallPresented)
        }
    }
}

#Preview {
    BottomSheetPreviewView()
}
#endif
