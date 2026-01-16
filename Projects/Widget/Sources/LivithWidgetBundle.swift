//
//  LivithWidgetBundle.swift
//  LivithWidget
//
//  Created by Youjin Lee on 1/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct LivithWidgetBundle: WidgetBundle {
    var body: some Widget {
        LivithWidget()
        LivithLargeWidget()
    }
}
