//
//  CalendarWebContentHeightMeasurer.swift
//  HomeFeature
//
//  Created by 김진웅 on 7/25/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WebKit

final class CalendarWebContentHeightMeasurer {

    // MARK: - Constants

    static let fallbackHeight: CGFloat = 700

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

    // MARK: - Properties

    private var contentHeightBinding: Binding<CGFloat>?
    private var measureGeneration = 0

    // MARK: - Methods

    func bind(_ binding: Binding<CGFloat>) {
        contentHeightBinding = binding
    }

    func resetToFallback() {
        Task { @MainActor [weak self] in
            guard let self,
                  let binding = self.contentHeightBinding,
                  binding.wrappedValue != Self.fallbackHeight
            else {
                return
            }
            binding.wrappedValue = Self.fallbackHeight
        }
    }

    func scheduleMeasurement(of webView: WKWebView) {
        measureGeneration += 1
        let generation = measureGeneration

        for delay in Constants.measureDelayList {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self,
                      self.measureGeneration == generation
                else {
                    return
                }
                self.evaluateContentHeight(of: webView)
            }
        }
    }
}

// MARK: - Private

private extension CalendarWebContentHeightMeasurer {
    enum Constants {
        static let measureDelayList: [TimeInterval] = [0.25, 0.5]
        static let updateThreshold: CGFloat = 0.5
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
                      abs(binding.wrappedValue - measuredHeight) > Constants.updateThreshold
                else {
                    return
                }
                binding.wrappedValue = measuredHeight
            }
        }
    }
}
