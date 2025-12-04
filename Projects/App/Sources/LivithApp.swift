import SwiftUI

import DSKit

@main
struct LivithApp: App {
    
    // MARK: - LifeCycle

    init() {
        registerDependency()
    }

    var body: some Scene {
        WindowGroup {
            LivithMainTabView()
        }
    }
}
