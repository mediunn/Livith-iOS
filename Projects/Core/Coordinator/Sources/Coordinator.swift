//
//  Coordinator.swift
//  Coordinator
//
//  Created by Youjin Lee on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import UIKit

/// 화면 전환 흐름을 관리하는 코디네이터 추상화.
///
/// - Note: `@MainActor`에서 동작하며 모든 UI 관련 트랜잭션을
///   메인 스레드에서 안전하게 처리합니다.
/// - Important: 코디네이터는 네비게이션 상태 일관성을 유지해야 하며,
///   `buildViewController(for:)`는 주어진 `Route`에 대한 화면 생성을
///   명확하고 예측 가능하게 구현해야 합니다.
///
/// 제네릭 파라미터
/// - `R`: 화면 전환을 정의하는 `Route` 타입
@MainActor
public protocol Coordinator: AnyObject {
    associatedtype R: Route

    /// 화면 전환을 주도하는 루트 `UINavigationController`.
    var navigationController: UINavigationController { get }

    /// 주어진 `route`에 대응하는 화면을 생성합니다.
    /// - Parameter route: 화면을 생성할 `Route`
    /// - Returns: 생성된 `UIViewController`
    ///
    /// - Tip: SwiftUI의 `View`를 사용해 화면을 구성한다면
    ///   UIKit과의 호환을 위해 `UIHostingController(rootView:)`로 감싸서 반환하세요.
    ///
    ///   예시:
    ///   ```swift
    ///   func buildViewController(for route: AppRoute) -> UIViewController {
    ///       switch route {
    ///       case .home:
    ///           let view = HomeView(viewModel: HomeViewModel())
    ///           return UIHostingController(rootView: view)
    ///       case .detail(let id):
    ///           let view = DetailView(id: id)
    ///           return UIHostingController(rootView: view)
    ///       }
    ///   }
    ///   ```
    func buildViewController(for route: R) -> UIViewController

    /// 코디네이터 시작 지점. 초기 화면 진입 로직을 구현합니다.
    func start()
}

public extension Coordinator {
    /// 지정한 `route`로 화면을 푸시합니다.
    /// - Parameters:
    ///   - route: 이동할 대상 `Route`
    ///   - animated: 애니메이션 여부. 기본값은 `true`
    func push(to route: R, animated: Bool = true) {
        let viewController = buildViewController(for: route)
        navigationController.pushViewController(viewController, animated: true)
    }

    /// 현재 화면을 하나 뒤로 되돌립니다.
    /// - Parameter animated: 애니메이션 여부. 기본값은 `true`
    func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }

    /// 루트 화면까지 되돌립니다.
    /// - Parameter animated: 애니메이션 여부. 기본값은 `true`
    func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }

    /// 지정한 `route`를 모달로 표시합니다.
    /// - Parameters:
    ///   - route: 표시할 대상 `Route`
    ///   - animated: 애니메이션 여부. 기본값은 `true`
    ///   - presentationStyle: `UIModalPresentationStyle` 지정 시 해당 스타일로 표시
    ///   - transitionStyle: `UIModalTransitionStyle` 지정 시 해당 전환 효과 적용
    ///   - completion: 표시 완료 후 호출되는 클로저
    func present(
        to route: R,
        animated: Bool = true,
        presentationStyle: UIModalPresentationStyle? = nil,
        transitionStyle: UIModalTransitionStyle? = nil,
        completion: (() -> Void)? = nil
    ) {
        let viewController = buildViewController(for: route)

        if let style = presentationStyle {
            viewController.modalPresentationStyle = style
        }

        if let style = transitionStyle {
            viewController.modalTransitionStyle = style
        }

        navigationController.present(viewController, animated: animated, completion: completion)
    }

    /// 현재 표시 중인 모달을 닫습니다.
    /// - Parameters:
    ///   - animated: 애니메이션 여부. 기본값은 `true`
    ///   - completion: 닫기 완료 후 호출되는 클로저
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
}
