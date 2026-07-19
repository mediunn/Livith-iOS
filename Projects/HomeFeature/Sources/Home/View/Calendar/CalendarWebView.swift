//
//  CalendarWebView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WebKit

import LivithDesignSystem

struct CalendarWebView: UIViewRepresentable {

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color.livithColor(.black100))
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.backgroundColor = UIColor(Color.livithColor(.black100))
        webView.load(URLRequest(url: Constants.blankURL))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Constants

private extension CalendarWebView {
    enum Constants {
        static let blankURL = URL(string: "about:blank")!
    }
}
