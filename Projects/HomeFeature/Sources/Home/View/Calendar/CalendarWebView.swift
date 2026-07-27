//
//  CalendarWebView.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/19/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WebKit

import Domain
import LivithDesignSystem

struct CalendarWebView: UIViewRepresentable {

    // MARK: - Properties

    let url: URL?
    let calendarMonth: CalendarMonth?
    @Binding var contentHeight: CGFloat
    let onDateSelected: (Date) -> Void
    let onMonthChanged: (String, String) -> Void

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(onDateSelected: onDateSelected, onMonthChanged: onMonthChanged)
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        let proxy = WeakScriptMessageHandlerProxy(target: context.coordinator)
        userContentController.add(proxy, name: Constants.dateSelectedHandlerName)
        userContentController.add(proxy, name: Constants.monthChangedHandlerName)
        userContentController.addUserScript(
            WKUserScript(
                source: CalendarWebContentHeightMeasurer.unlockViewportHeightScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color.livithColor(.black100))
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.backgroundColor = UIColor(Color.livithColor(.black100))

        context.coordinator.loadSession.calendarURL = url
        context.coordinator.loadSession.updatePendingPayload(from: calendarMonth)
        context.coordinator.contentHeightMeasurer.bind($contentHeight)

        if let url {
            webView.load(URLRequest(url: url))
        } else if let blankURL = Constants.blankURL {
            webView.load(URLRequest(url: blankURL))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onDateSelected = onDateSelected
        context.coordinator.onMonthChanged = onMonthChanged
        context.coordinator.contentHeightMeasurer.bind($contentHeight)
        context.coordinator.loadSession.updatePendingPayload(from: calendarMonth)
        context.coordinator.loadSession.reloadCalendarURLIfNeeded(into: uiView)
        context.coordinator.loadSession.injectIfNeeded(
            into: uiView,
            contentHeightMeasurer: context.coordinator.contentHeightMeasurer
        )
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        let userContentController = uiView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: Constants.dateSelectedHandlerName)
        userContentController.removeScriptMessageHandler(forName: Constants.monthChangedHandlerName)
    }
}

// MARK: - Coordinator

extension CalendarWebView {
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onDateSelected: (Date) -> Void
        var onMonthChanged: (String, String) -> Void
        let loadSession = CalendarWebLoadSession()
        let contentHeightMeasurer = CalendarWebContentHeightMeasurer()

        init(
            onDateSelected: @escaping (Date) -> Void,
            onMonthChanged: @escaping (String, String) -> Void
        ) {
            self.onDateSelected = onDateSelected
            self.onMonthChanged = onMonthChanged
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            loadSession.handleDidFinish(
                navigationOn: webView,
                contentHeightMeasurer: contentHeightMeasurer
            )
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            loadSession.handleLoadFailure(on: webView)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            loadSession.handleLoadFailure(on: webView)
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            switch message.name {
            case Constants.dateSelectedHandlerName:
                guard let date = CalendarDateSelectedMessageParser.date(from: message.body) else {
                    return
                }
                Task { @MainActor in
                    onDateSelected(date)
                }

            case Constants.monthChangedHandlerName:
                guard let dateRange = CalendarMonthChangedMessageParser.dateRange(from: message.body) else {
                    return
                }
                Task { @MainActor in
                    onMonthChanged(dateRange.startDate, dateRange.endDate)
                }

            default:
                return
            }
        }
    }
}

// MARK: - WeakScriptMessageHandlerProxy

fileprivate final class WeakScriptMessageHandlerProxy: NSObject, WKScriptMessageHandler {
    weak var target: WKScriptMessageHandler?

    init(target: WKScriptMessageHandler) {
        self.target = target
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        target?.userContentController(userContentController, didReceive: message)
    }
}

// MARK: - Constants

private enum Constants {
    static let blankURL = URL(string: "about:blank")
    static let dateSelectedHandlerName = "calendarDateSelected"
    static let monthChangedHandlerName = "calendarMonthChanged"
}
