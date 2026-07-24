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
import LivithFoundation

struct CalendarWebView: UIViewRepresentable {

    // MARK: - Properties

    let url: URL?
    let calendarMonth: CalendarMonth?
    let onDateSelected: (Date) -> Void

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(onDateSelected: onDateSelected)
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        let proxy = WeakScriptMessageHandlerProxy(target: context.coordinator)
        userContentController.add(proxy, name: Constants.dateSelectedHandlerName)
        context.coordinator.messageHandlerProxy = proxy

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color.livithColor(.black100))
        // TODO: WebView·래퍼(ScrollView) 이중 스크롤·높이(남은 화면 채우기) 정리.
        // VStack + UIRefreshControl 또는 ScrollView 잔여 높이 중 하나로 PTR/레이아웃을 맞출 것.
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        webView.scrollView.backgroundColor = UIColor(Color.livithColor(.black100))

        context.coordinator.calendarURL = url
        context.coordinator.updatePendingPayload(from: calendarMonth)

        if let url {
            webView.load(URLRequest(url: url))
        } else if let blankURL = Constants.blankURL {
            webView.load(URLRequest(url: blankURL))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onDateSelected = onDateSelected
        context.coordinator.updatePendingPayload(from: calendarMonth)
        context.coordinator.injectIfNeeded(into: uiView)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController
            .removeScriptMessageHandler(forName: Constants.dateSelectedHandlerName)
        coordinator.messageHandlerProxy = nil
    }
}

// MARK: - Coordinator

extension CalendarWebView {
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onDateSelected: (Date) -> Void
        var calendarURL: URL?
        var hasLoadedCalendarURL = false
        var pendingPayloadJSON: String?
        fileprivate var messageHandlerProxy: WeakScriptMessageHandlerProxy?

        init(onDateSelected: @escaping (Date) -> Void) {
            self.onDateSelected = onDateSelected
        }

        func updatePendingPayload(from month: CalendarMonth?) {
            pendingPayloadJSON = month.flatMap { CalendarWebMonthPayloadMapper.jsonString(from: $0) }
        }

        func injectIfNeeded(into webView: WKWebView) {
            guard hasLoadedCalendarURL, let pendingPayloadJSON else { return }
            guard let escapedLiteral = Self.jsonStringLiteral(from: pendingPayloadJSON) else { return }

            let script = "window.setCalendarData(JSON.parse(\(escapedLiteral)))"
            webView.evaluateJavaScript(script, completionHandler: nil)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard calendarURL != nil,
                  let blankURL = Constants.blankURL,
                  webView.url != blankURL
            else {
                return
            }

            hasLoadedCalendarURL = true
            injectIfNeeded(into: webView)
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            handleLoadFailure(on: webView)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            handleLoadFailure(on: webView)
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == Constants.dateSelectedHandlerName,
                  let date = Self.parseSelectedDate(from: message.body)
            else {
                return
            }

            onDateSelected(date)
        }
    }
}

// MARK: - Coordinator Helpers

private extension CalendarWebView.Coordinator {
    func handleLoadFailure(on webView: WKWebView) {
        hasLoadedCalendarURL = false
        calendarURL = nil
        guard let blankURL = Constants.blankURL else { return }
        webView.load(URLRequest(url: blankURL))
    }

    static func jsonStringLiteral(from json: String) -> String? {
        guard let data = try? JSONEncoder().encode(json) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func parseSelectedDate(from body: Any) -> Date? {
        let dateString: String?
        if let dictionary = body as? [String: Any] {
            dateString = dictionary["date"] as? String
        } else if let string = body as? String,
                  let data = string.data(using: .utf8),
                  let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            dateString = dictionary["date"] as? String
        } else {
            dateString = nil
        }

        guard let dateString else { return nil }
        return DateFormatterService.date(from: dateString, type: .dashDate)
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
}
