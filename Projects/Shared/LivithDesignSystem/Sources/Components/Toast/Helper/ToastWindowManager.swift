//
//  ToastWindowManager.swift
//  LivithDesignSystem
//
//  Created by 김진웅 on 01/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import UIKit

@MainActor
final class ToastWindowManager {
    static let shared = ToastWindowManager()
    
    private var toastWindow: UIWindow?
    private var hostingController: UIHostingController<AnyView>?
    
    private init() {}
    
    func show(
        scene: UIWindowScene,
        environment: EnvironmentValues,
        content: ToastContent,
        configuration: ToastConfiguration,
        onDismiss: @escaping () -> Void
    ) {
        dismiss()
        
        let window = PassthroughWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        
        let toastContainer = ToastContainerView(
            content: content,
            configuration: configuration
        ) { [weak self] in
            self?.dismiss()
            onDismiss()
        }
        
        let envView = EnvPassingView(content: toastContainer, environment: environment)
        
        let hostingController = UIHostingController(rootView: AnyView(envView))
        hostingController.view.backgroundColor = .clear
        
        window.rootViewController = hostingController
        window.isHidden = false
        
        self.toastWindow = window
        self.hostingController = hostingController
    }
    
    func dismiss() {
        toastWindow?.isHidden = true
        toastWindow = nil
        hostingController = nil
    }
}
