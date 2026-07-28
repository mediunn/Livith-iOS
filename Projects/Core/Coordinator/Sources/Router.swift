//
//  Router.swift
//  Coordinator
//
//  Created by on 6/15/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import SwiftUI

/// SwiftUI 네이티브 NavigationStack을 위한 라우터 기반 클래스.
///
/// - Note: `@MainActor`에서 동작하며 `NavigationPath`를 통해
///   선언적 화면 전환을 관리합니다.
/// - Important: `path`는 `private(set)`으로 보호되며,
///   화면 전환은 반드시 `push`, `pop`, `popToRoot` 메서드를 통해야 합니다.
///
/// 제네릭 파라미터
/// - `R`: 화면 전환을 정의하는 `Hashable` Route 타입
@MainActor
open class Router<R: Hashable>: ObservableObject {
    @Published public var path = NavigationPath()

    public init() {}

    /// 지정한 `route`를 네비게이션 스택에 추가합니다.
    /// - Parameter route: 이동할 대상 `Route`
    open func push(_ route: R) {
        path.append(route)
    }

    /// 현재 화면을 하나 뒤로 되돌립니다.
    open func pop() {
        path.removeLast()
    }

    /// 루트 화면까지 되돌립니다.
    open func popToRoot() {
        path.removeLast(path.count)
    }
}
