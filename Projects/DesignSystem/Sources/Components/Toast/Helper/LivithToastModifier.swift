//
//  LivithToastModifier.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 01/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

// MARK: - Toast Content

struct ToastContent {
    let type: LivithToastType
    let message: String
}

// MARK: - Toast Configuration

struct ToastConfiguration {
    let duration: TimeInterval?
    let topPadding: CGFloat
    let position: LivithToastPosition
    let keyboardSpacing: CGFloat
    
    static let `default` = ToastConfiguration(
        duration: 2.0,
        topPadding: 10,
        position: .safeAreaTop,
        keyboardSpacing: 16
    )
}

// MARK: - Modifier

struct LivithToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let type: LivithToastType
    let message: String
    
    @Environment(\.self) var environment
    @State private var windowScene: UIWindowScene?
    
    func body(content: Content) -> some View {
        content
            .background(
                WindowSceneFinder { scene in
                    self.windowScene = scene
                }
            )
            .onChange(of: isPresented) { _, newValue in
                handlePresentationChange(isPresented: newValue)
            }
    }
    
    private func handlePresentationChange(isPresented: Bool) {
        guard isPresented else {
            ToastWindowManager.shared.dismiss()
            return
        }
        
        guard let scene = windowScene else {
            print("⚠️ UIWindowScene not found")
            self.isPresented = false
            return
        }
        
        ToastWindowManager.shared.show(
            scene: scene,
            environment: environment,
            content: ToastContent(type: type, message: message),
            configuration: .default,
            onDismiss: { self.isPresented = false }
        )
    }
}
