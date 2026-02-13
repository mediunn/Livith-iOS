//
//  AmplitudeManager.swift
//  Amplitude
//
//  Created by Youjin Lee on 2/14/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import AmplitudeSwift

public final class AmplitudeManager {
    public static let shared = AmplitudeManager()

    private let amplitude: Amplitude

    private init() {
        amplitude = Amplitude(configuration: Configuration(apiKey: Bundle.amplitudeAppKey))
    }

    public func trackEvent(tag: EventTag) {
        amplitude.track(eventType: tag.value)
    }
}
