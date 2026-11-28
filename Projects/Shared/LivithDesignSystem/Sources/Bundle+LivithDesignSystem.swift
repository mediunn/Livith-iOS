//
//  Bundle+LivithDesignSystem.swift
//  LivithDesignSystem
//
//  Created by Youjin Lee on 1/12/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

private class BundleFinder {}

public extension Bundle {
    /// LivithDesignSystem 리소스 번들
    static let livithDesignSystem: Bundle = {
        // Tuist/Xcode 프레임워크 빌드: 리소스가 프레임워크 번들에 직접 포함됨
        let frameworkBundle = Bundle(for: BundleFinder.self)

        // 프레임워크 번들에 리소스가 있는지 확인 (Tuist 빌드)
        if frameworkBundle.url(forResource: "ColorAssets", withExtension: "xcassets") != nil ||
           frameworkBundle.url(forResource: "NotoSansKR-Bold", withExtension: "ttf") != nil {
            return frameworkBundle
        }

        // SPM 빌드: 별도의 리소스 번들 사용
        let bundleName = "LivithDesignSystem_LivithDesignSystem"

        let candidates = [
            Bundle.main.resourceURL,
            frameworkBundle.resourceURL,
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        // 프레임워크 빌드 시 해당 클래스를 포함하는 번들로 폴백
        return frameworkBundle
    }()
}
