//
//  EventTag.swift
//  Amplitude
//
//  Created by Youjin Lee on 2/14/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum EventTag {
    case screenView(String)
    case buttonTap(String)
    case custom(String)

    public var value: String {
        switch self {
        case .screenView(let name):
            return "screen_view_\(name)"
        case .buttonTap(let name):
            return "button_tap_\(name)"
        case .custom(let name):
            return name
        }
    }
}
