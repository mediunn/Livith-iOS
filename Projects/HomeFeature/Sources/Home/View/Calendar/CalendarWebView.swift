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

    // MARK: - UIViewRepresentable

    func makeCoordinator() -> Coordinator {
        Coordinator(onDateSelected: onDateSelected)
    }

    func makeUIView(context: Context) -> WKWebView {
        let userContentController = WKUserContentController()
        let proxy = WeakScriptMessageHandlerProxy(target: context.coordinator)
        userContentController.add(proxy, name: Constants.dateSelectedHandlerName)
        userContentController.addUserScript(
            WKUserScript(
                source: Constants.unlockViewportHeightScript,
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

        context.coordinator.calendarURL = url
        context.coordinator.updatePendingPayload(from: calendarMonth)
        context.coordinator.bindContentHeight($contentHeight)

        if let url {
            webView.load(URLRequest(url: url))
        } else if let blankURL = Constants.blankURL {
            webView.load(URLRequest(url: blankURL))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onDateSelected = onDateSelected
        context.coordinator.bindContentHeight($contentHeight)
        context.coordinator.updatePendingPayload(from: calendarMonth)
        context.coordinator.reloadCalendarURLIfNeeded(into: uiView)
        context.coordinator.injectIfNeeded(into: uiView)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController
            .removeScriptMessageHandler(forName: Constants.dateSelectedHandlerName)
    }
}

// MARK: - Coordinator

extension CalendarWebView {
    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var onDateSelected: (Date) -> Void
        var calendarURL: URL?
        var hasLoadedCalendarURL = false
        var pendingPayloadJSON: String?
        var lastInjectedPayloadJSON: String?

        private var contentHeightBinding: Binding<CGFloat>?
        private var contentHeightMeasureGeneration = 0
        private var lastReloadAttemptDate: Date?

        init(onDateSelected: @escaping (Date) -> Void) {
            self.onDateSelected = onDateSelected
        }

        func bindContentHeight(_ binding: Binding<CGFloat>) {
            contentHeightBinding = binding
        }

        func updatePendingPayload(from month: CalendarMonth?) {
            pendingPayloadJSON = month.flatMap { CalendarWebMonthPayloadMapper.jsonString(from: $0) }
        }

        func reloadCalendarURLIfNeeded(into webView: WKWebView) {
            guard !hasLoadedCalendarURL,
                  let calendarURL,
                  let blankURL = Constants.blankURL,
                  webView.url == nil || webView.url == blankURL
            else {
                return
            }

            if let lastReloadAttemptDate,
               Date().timeIntervalSince(lastReloadAttemptDate) < Constants.reloadCooldownInterval {
                return
            }

            lastReloadAttemptDate = Date()
            webView.load(URLRequest(url: calendarURL))
        }

        func injectIfNeeded(into webView: WKWebView) {
            guard hasLoadedCalendarURL, let pendingPayloadJSON else { return }
            guard pendingPayloadJSON != lastInjectedPayloadJSON else { return }
            guard let escapedLiteral = Self.jsonStringLiteral(from: pendingPayloadJSON) else { return }

            let script = "window.setCalendarData(JSON.parse(\(escapedLiteral)))"
            let injectingPayloadJSON = pendingPayloadJSON
            webView.evaluateJavaScript(script) { [weak self] _, error in
                guard let self else { return }

                if error == nil {
                    self.lastInjectedPayloadJSON = injectingPayloadJSON
                }
                self.scheduleContentHeightMeasurement(of: webView)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard !webView.isLoading else { return }
            guard calendarURL != nil,
                  let blankURL = Constants.blankURL,
                  webView.url != blankURL
            else {
                return
            }

            let shouldMeasureWithoutWaitingForInject: Bool = {
                guard let pendingPayloadJSON else { return true }
                return pendingPayloadJSON == lastInjectedPayloadJSON
            }()

            hasLoadedCalendarURL = true
            injectIfNeeded(into: webView)

            if shouldMeasureWithoutWaitingForInject {
                scheduleContentHeightMeasurement(of: webView)
            }
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
                  let date = CalendarDateSelectedMessageParser.date(from: message.body)
            else {
                return
            }

            Task { @MainActor in
                onDateSelected(date)
            }
        }
    }
}

// MARK: - Coordinator Helpers

private extension CalendarWebView.Coordinator {
    func handleLoadFailure(on webView: WKWebView) {
        hasLoadedCalendarURL = false
        lastInjectedPayloadJSON = nil
        guard let blankURL = Constants.blankURL else { return }
        webView.load(URLRequest(url: blankURL))
    }

    func scheduleContentHeightMeasurement(of webView: WKWebView) {
        contentHeightMeasureGeneration += 1
        let generation = contentHeightMeasureGeneration

        for delay in Constants.contentHeightMeasureDelayList {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self,
                      self.contentHeightMeasureGeneration == generation
                else {
                    return
                }
                self.evaluateContentHeight(of: webView)
            }
        }
    }

    func evaluateContentHeight(of webView: WKWebView) {
        webView.evaluateJavaScript(Constants.contentHeightScript) { [weak self] result, _ in
            guard let self,
                  let number = result as? NSNumber
            else {
                return
            }

            let measuredHeight = CGFloat(truncating: number)
            guard measuredHeight > 0 else { return }

            Task { @MainActor in
                guard let binding = self.contentHeightBinding,
                      abs(binding.wrappedValue - measuredHeight) > 0.5
                else {
                    return
                }
                binding.wrappedValue = measuredHeight
            }
        }
    }

    static func jsonStringLiteral(from json: String) -> String? {
        guard let data = try? JSONEncoder().encode(json) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
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
    static let reloadCooldownInterval: TimeInterval = 2
    static let contentHeightMeasureDelayList: [TimeInterval] = [0.25, 0.5]
    static let unlockViewportHeightScript = """
    (function() {
      var styleId = 'livith-calendar-height-unlock';
      if (document.getElementById(styleId)) { return; }
      var style = document.createElement('style');
      style.id = styleId;
      style.textContent = [
        'html, body, #root, #__next, #app, main {',
        '  height: auto !important;',
        '  min-height: 0 !important;',
        '  max-height: none !important;',
        '  overflow: visible !important;',
        '}',
        '.h-screen, .min-h-screen, .h-dvh, .min-h-dvh, .h-full, .min-h-full {',
        '  height: auto !important;',
        '  min-height: 0 !important;',
        '  max-height: none !important;',
        '}'
      ].join('\\n');
      document.head.appendChild(style);
    })();
    """
    static let contentHeightScript = """
    (function() {
      var maxBottom = 0;
      var nodes = document.body ? document.body.getElementsByTagName('*') : [];
      for (var i = 0; i < nodes.length; i++) {
        var el = nodes[i];
        var style = window.getComputedStyle(el);
        if (style.display === 'none' || style.visibility === 'hidden') { continue; }
        if (style.position === 'fixed') { continue; }
        var rect = el.getBoundingClientRect();
        if (rect.height === 0) { continue; }
        maxBottom = Math.max(maxBottom, rect.bottom + window.pageYOffset);
      }
      return Math.ceil(maxBottom);
    })()
    """
}
