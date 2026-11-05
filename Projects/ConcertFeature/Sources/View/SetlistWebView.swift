//
//  SetlistWebView.swift
//  ConcertFeature
//

import SwiftUI
import WebKit

import LivithDesignSystem

struct SetlistWebView: View {
    let concertID: Int
    let setlistID: Int

    @Environment(\.dismiss) private var dismiss
    @State private var loadFailed = false

    var body: some View {
        ZStack {
            Color.livithColor(.black100).ignoresSafeArea()
            SetlistWebContent(
                concertID: concertID,
                setlistID: setlistID,
                loadFailed: $loadFailed,
                onClose: { dismiss() }
            )
            .ignoresSafeArea(edges: .bottom)
            if loadFailed {
                VStack(spacing: 16) {
                    Text("웹 화면을 불러올 수 없어요")
                        .foregroundStyle(.white)
                    Button("돌아가기") { dismiss() }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SetlistWebContent: UIViewRepresentable {
    let concertID: Int
    let setlistID: Int
    @Binding var loadFailed: Bool
    let onClose: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(loadFailed: $loadFailed, onClose: onClose)
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
        webView.scrollView.bounces = false
        if let url = URL(string: "http://localhost:5173/app/setlist/\(setlistID)/\(concertID)") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "setlistWebView")
        webView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        @Binding private var loadFailed: Bool
        private let onClose: () -> Void

        init(loadFailed: Binding<Bool>, onClose: @escaping () -> Void) {
            self._loadFailed = loadFailed
            self.onClose = onClose
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.frameInfo.isMainFrame,
                  message.frameInfo.securityOrigin.host == "localhost",
                  message.frameInfo.securityOrigin.port == 5173,
                  message.body as? String == "close" else { return }
            onClose()
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            if let frame = navigationAction.targetFrame, !frame.isMainFrame {
                decisionHandler(.allow)
                return
            }
            if url.scheme == "http", url.host == "localhost", url.port == 5173 {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
                if url.scheme == "https" || url.scheme == "http" {
                    UIApplication.shared.open(url)
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            loadFailed = true
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            loadFailed = true
        }
    }
}
