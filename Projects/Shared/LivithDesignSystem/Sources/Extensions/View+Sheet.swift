//
//  View+Sheet.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 2026/01/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

extension View {
    
    /// Livith 디자인 시스템에 맞는 sheet를 표시합니다.
    /// 기본적으로 검은색 배경과 드래그 인디케이터, 둥근 모서리가 적용됩니다.
    ///
    /// - Parameters:
    ///   - isPresented: sheet 표시 여부를 제어하는 바인딩
    ///   - detents: 시트의 가능한 높이들 (기본값: `[.medium]`)
    ///   - background: 배경색 (기본값: `black90`)
    ///   - cornerRadius: 모서리 반경 (기본값: `20`)
    ///   - content: 표시할 콘텐츠
    /// - Returns: sheet가 적용된 뷰
    public func livithSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium],
        background: Color = .livithColor(.black90),
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            content()
                .presentationDetents(detents)
                .presentationDragIndicator(.visible)
                .presentationBackground(background)
                .presentationCornerRadius(cornerRadius)
        }
    }
}
