//
//  Routing.swift
//  core
//
//  Created by 김진웅 on 10/12/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI

@MainActor
public protocol Routing: AnyObject {
    associatedtype Route: Routable
    
    var path: NavigationPath { get set }
    var sheet: Route? { get set }
    var fullScreenCover: Route? { get set }
    
    @ViewBuilder
    func view(to route: Route, with style: PresentationStyle) -> AnyView
}

public extension Routing {
    func push(_ page: Route...) {
        page.forEach {
            path.append($0)
        }
    }
    
    func sheet(_ sheet: Route) {
        self.sheet = sheet
    }
    
    func fullScreenCover(_ fullScreenCover: Route) {
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
