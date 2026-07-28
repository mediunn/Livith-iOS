//
//  CalendarWebLoadSession.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/25/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import WebKit

import Domain

final class CalendarWebLoadSession {

    // MARK: - Properties

    var calendarURL: URL?
    var hasLoadedCalendarURL = false
    var pendingPayloadJSON: String?
    var lastInjectedPayloadJSON: String?

    private var lastReloadAttemptDate: Date?

    // MARK: - Methods

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

    func injectIfNeeded(
        into webView: WKWebView,
        contentHeightMeasurer: CalendarWebContentHeightMeasurer
    ) {
        guard hasLoadedCalendarURL, let pendingPayloadJSON else { return }
        guard pendingPayloadJSON != lastInjectedPayloadJSON else { return }
        guard let escapedLiteral = Self.jsonStringLiteral(from: pendingPayloadJSON) else { return }

        contentHeightMeasurer.resetToFallback()

        let script = "window.setCalendarData(JSON.parse(\(escapedLiteral)))"
        let injectingPayloadJSON = pendingPayloadJSON
        webView.evaluateJavaScript(script) { [weak self] _, error in
            guard let self else { return }

            if error == nil {
                self.lastInjectedPayloadJSON = injectingPayloadJSON
            }
            contentHeightMeasurer.scheduleMeasurement(of: webView)
        }
    }

    func handleDidFinish(
        navigationOn webView: WKWebView,
        contentHeightMeasurer: CalendarWebContentHeightMeasurer
    ) {
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
        injectIfNeeded(into: webView, contentHeightMeasurer: contentHeightMeasurer)

        if shouldMeasureWithoutWaitingForInject {
            contentHeightMeasurer.scheduleMeasurement(of: webView)
        }
    }

    func handleLoadFailure(on webView: WKWebView) {
        hasLoadedCalendarURL = false
        lastInjectedPayloadJSON = nil
        guard let blankURL = Constants.blankURL else { return }
        webView.load(URLRequest(url: blankURL))
    }
}

// MARK: - Private

private extension CalendarWebLoadSession {
    enum Constants {
        static let blankURL = URL(string: "about:blank")
        static let reloadCooldownInterval: TimeInterval = 2
    }

    static func jsonStringLiteral(from json: String) -> String? {
        guard let data = try? JSONEncoder().encode(json) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
