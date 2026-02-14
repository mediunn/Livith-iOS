//
//  Bundle+Amplitude.swift
//  Amplitude
//
//  Created by Youjin Lee on 2/14/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

extension Bundle {
    static let amplitudeAppKey: String = {
        let bundle = Bundle(identifier: "com.youz2me.livith.amplitude") ?? Bundle.main

        guard let key = bundle.object(forInfoDictionaryKey: "AMPLITUDE_API_KEY") as? String else {
            fatalError("AMPLITUDE_API_KEY를 찾을 수 없습니다.")
        }

        return key
    }()
}
