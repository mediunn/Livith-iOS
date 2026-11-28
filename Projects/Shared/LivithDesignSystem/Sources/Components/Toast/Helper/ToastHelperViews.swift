//
//  ToastHelperViews.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 01/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import UIKit

// MARK: - Window Scene Finder

struct WindowSceneFinder: UIViewRepresentable {
    var onFound: (UIWindowScene) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = WindowSceneFinderView()
        view.onFound = onFound
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private class WindowSceneFinderView: UIView {
        var onFound: ((UIWindowScene) -> Void)?
        
        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let windowScene = window?.windowScene {
                onFound?(windowScene)
            }
        }
    }
}

// MARK: - Environment Passing View

struct EnvPassingView<Content: View>: View {
    let content: Content
    let environment: EnvironmentValues
    
    var body: some View {
        content
            .transformEnvironment(\.self) { target in
                target = environment
            }
    }
}

// MARK: - Passthrough Window

final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return hitView == rootViewController?.view ? nil : hitView
    }
}
