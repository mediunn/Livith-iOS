//
//  SafariView.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 12/10/25.
//  Copyright © 2026 Livith. All rights reserved.
//

import SafariServices
import SwiftUI

public struct SafariView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: (() -> Void)?
    
    public init(url: URL, onDismiss: (() -> Void)? = nil) {
        self.url = url
        self.onDismiss = onDismiss
    }
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = context.coordinator
        return safariViewController
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    public class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let onDismiss: (() -> Void)?
        
        init(onDismiss: (() -> Void)?) {
            self.onDismiss = onDismiss
        }
        
        public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onDismiss?()
        }
    }
}
