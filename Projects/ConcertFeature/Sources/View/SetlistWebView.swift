//
//  SetlistWebView.swift
//  ConcertFeature
//

import CoreFoundation
import SwiftUI
import WebKit

import Amplitude
import DIContainer
import LivithDesignSystem

struct SetlistWebView: View {
    let concertID: Int
    let setlistID: Int

    @Injected private var webConfig: SetlistWebConfig

    @Environment(\.dismiss) private var dismiss
    @State private var loadFailed = false

    var body: some View {
        ZStack {
            Color.livithColor(.black100).ignoresSafeArea()
            SetlistWebContent(
                concertID: concertID,
                setlistID: setlistID,
                webConfig: webConfig,
                loadFailed: $loadFailed,
                onClose: { dismiss() }
            )
            .ignoresSafeArea(edges: .bottom)
            if loadFailed {
                VStack(spacing: 0) {
                    LivithNavigationView(type: .back(title: "셋리스트", onBack: { dismiss() }))
                    LivithEmptyView(text: "셋리스트를 불러오지 못했어요")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.livithColor(.black100).ignoresSafeArea())
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SetlistWebContent: UIViewRepresentable {
    let concertID: Int
    let setlistID: Int
    let webConfig: SetlistWebConfig
    @Binding var loadFailed: Bool
    let onClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(webConfig: webConfig, loadFailed: $loadFailed, onClose: onClose)
    }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "setlistWebView")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color.livithColor(.black100))
        if let url = webConfig.setlistURL(concertID: concertID, setlistID: setlistID) {
            webView.load(URLRequest(url: url))
        } else {
            DispatchQueue.main.async { loadFailed = true }
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "setlistWebView")
        webView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        private let webConfig: SetlistWebConfig
        private var hasPendingReportTap = false
        @Binding private var loadFailed: Bool
        private let onClose: () -> Void

        init(webConfig: SetlistWebConfig, loadFailed: Binding<Bool>, onClose: @escaping () -> Void) {
            self.webConfig = webConfig
            self._loadFailed = loadFailed
            self.onClose = onClose
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "setlistWebView",
                  message.frameInfo.isMainFrame,
                  webConfig.allowsOrigin(
                    scheme: message.frameInfo.securityOrigin.protocol,
                    host: message.frameInfo.securityOrigin.host,
                    port: message.frameInfo.securityOrigin.port
                  ) else { return }

            if message.body as? String == "close" {
                onClose()
                return
            }

            guard let body = message.body as? [String: Any],
                  let type = body["type"] as? String else { return }

            let toggle: AmplitudeService.ToggleEvent
            switch type {
            case "onSongTap":
                AmplitudeService.shared.trackEvent(tag: .click(.songCell))
                return
            case "onSetlistReportTap":
                hasPendingReportTap = true
                AmplitudeService.shared.trackEvent(tag: .click(.reportSetlist))
                return
            case "onSongReportTap":
                hasPendingReportTap = true
                AmplitudeService.shared.trackEvent(tag: .click(.reportSong))
                return
            case "onOriginalToggle":
                toggle = .original
            case "onPronunciationToggle":
                toggle = .pronunciation
            case "onTranslationToggle":
                toggle = .translation
            case "onCheerToggle":
                toggle = .cheer
            default:
                return
            }

            guard let isOn = body["isOn"] as? NSNumber,
                  CFGetTypeID(isOn) == CFBooleanGetTypeID() else { return }
            AmplitudeService.shared.trackEvent(tag: .toggle(toggle, isOn: isOn.boolValue))
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            guard let scheme = url.scheme,
                  scheme == "https" || scheme == "http",
                  let host = url.host else {
                decisionHandler(.cancel)
                return
            }
            if let frame = navigationAction.targetFrame, !frame.isMainFrame,
               navigationAction.navigationType != .linkActivated {
                decisionHandler(.allow)
                return
            }

            let isUserNavigation = navigationAction.navigationType == .linkActivated || hasPendingReportTap
            hasPendingReportTap = false
            if isUserNavigation, !webConfig.allowsOrigin(scheme: scheme, host: host, port: url.port) {
                decisionHandler(.cancel)
                UIApplication.shared.open(url)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            loadFailed = true
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loadFailed = true
        }
    }
}
