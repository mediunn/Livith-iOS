//
//  BundleIdentifier.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

public enum BundleIdentifier {
    public static func of(_ module: Module) -> String {
        if module == .app {
            return base
        }
        return "\(base).\(module.name)"
    }
}

// MARK: - Constant

extension BundleIdentifier {
    private static let base = "com.youz2me.livith"
}
