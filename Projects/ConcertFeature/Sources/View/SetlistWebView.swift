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
import SongFeature

private struct SelectedSong: Hashable {
    let id: Int
    let title: String
}

struct SetlistWebView: View {
    let concertID: Int
    let setlistID: Int

    @Injected private var webConfig: SetlistWebConfig

    @Environment(\.dismiss) private var dismiss
    @State private var loadFailed = false
    @State private var pendingSong: SelectedSong?
    @State private var headerTitle: String?

    var body: some View {
        VStack(spacing: 0) {
            if headerTitle != nil || loadFailed {
                LivithNavigationView(type: .back(title: headerTitle ?? "셋리스트", onBack: { dismiss() }))
                    .padding(.horizontal, 16)
            }
            ZStack {
                Color.livithColor(.black100).ignoresSafeArea()
                SetlistWebContent(
                    concertID: concertID,
                    setlistID: setlistID,
                    webConfig: webConfig,
                    loadFailed: $loadFailed,
                    onClose: { dismiss() },
                    onSongTap: { pendingSong = $0 },
                    onHeaderTitle: { headerTitle = $0 }
                )
                .ignoresSafeArea(edges: .bottom)
                if loadFailed {
                    LivithEmptyView(text: "셋리스트를 불러오지 못했어요")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.livithColor(.black100).ignoresSafeArea())
                }
            }
        }
        .background(Color.livithColor(.black100))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $pendingSong) { song in
            SongLyricsView(songID: song.id, setlistID: setlistID, songTitle: song.title)
        }
    }
}

private struct SetlistWebContent: UIViewRepresentable {
    let concertID: Int
    let setlistID: Int
    let webConfig: SetlistWebConfig
    @Binding var loadFailed: Bool
    let onClose: () -> Void
    let onSongTap: (SelectedSong) -> Void
    let onHeaderTitle: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(webConfig: webConfig, loadFailed: $loadFailed, onClose: onClose, onSongTap: onSongTap, onHeaderTitle: onHeaderTitle)
    }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "setlistWebView")
        controller.add(context.coordinator, name: "setlistNativeNavigation")
        controller.add(context.coordinator, name: "setlistNativeHeader")
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
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "setlistNativeNavigation")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "setlistNativeHeader")
        webView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        private let webConfig: SetlistWebConfig
        private var hasPendingReportTap = false
        @Binding private var loadFailed: Bool
        private let onClose: () -> Void
        private let onSongTap: (SelectedSong) -> Void
        private let onHeaderTitle: (String) -> Void

        init(webConfig: SetlistWebConfig, loadFailed: Binding<Bool>, onClose: @escaping () -> Void, onSongTap: @escaping (SelectedSong) -> Void, onHeaderTitle: @escaping (String) -> Void) {
            self.webConfig = webConfig
            self._loadFailed = loadFailed
            self.onClose = onClose
            self.onSongTap = onSongTap
            self.onHeaderTitle = onHeaderTitle
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard (message.name == "setlistWebView" || message.name == "setlistNativeNavigation" || message.name == "setlistNativeHeader"),
                  message.frameInfo.isMainFrame,
                  webConfig.allowsOrigin(
                    scheme: message.frameInfo.securityOrigin.protocol,
                    host: message.frameInfo.securityOrigin.host,
                    port: message.frameInfo.securityOrigin.port
                  ) else { return }

            if message.name == "setlistNativeHeader" {
                guard let body = message.body as? [String: Any],
                      let title = body["title"] as? String, title.count <= 500 else { return }
                onHeaderTitle(title)
                return
            }

            if message.name == "setlistNativeNavigation" {
                guard let body = message.body as? [String: Any],
                      let type = body["type"] as? String else { return }
                if type == "openSong",
                          let value = body["songId"] as? NSNumber,
                          CFGetTypeID(value) != CFBooleanGetTypeID(),
                          value.doubleValue == Double(value.intValue), value.intValue > 0 {
                    let title = (body["songTitle"] as? String).map { String($0.prefix(500)) } ?? "노래"
                    onSongTap(SelectedSong(id: value.intValue, title: title))
                }
                return
            }

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
