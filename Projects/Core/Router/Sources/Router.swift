//
//  Router.swift
//  core
//
//  Created by 김진웅 on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

@MainActor
public protocol Router: ObservableObject {
    associatedtype R: Route
    
    var path: NavigationPath { get set }
    var sheet: R? { get set }
    var fullScreenCover: R? { get set }
    
    @ViewBuilder
    func view(to route: R, with style: PresentationStyle) -> AnyView
}

public extension Router {
    func push(_ page: R...) {
        page.forEach {
            path.append($0)
        }
    }
    
    func sheet(_ sheet: R) {
        self.sheet = sheet
    }
    
    func fullScreenCover(_ fullScreenCover: R) {
        self.fullScreenCover = fullScreenCover
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        guard !path.isEmpty else { return }
        let count = path.count
        path.removeLast(count)
    }
    
    func dismissSheet() {
        sheet = nil
    }
    
    func dismissFullScreen() {
        fullScreenCover = nil
    }
}
