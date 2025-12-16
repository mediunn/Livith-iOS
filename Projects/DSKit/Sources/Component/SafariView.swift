//
//  SafariView.swift
//  DSKit
//
//  Created by Youjin Lee on 12/10/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SafariServices
import SwiftUI

public struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
