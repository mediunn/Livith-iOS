import Testing

@testable import LivithNetworking

@Suite("LivithNetworking 모듈")
struct LivithNetworkingModuleTests {
    @Test("모듈을 import할 수 있어야 한다")
    func 모듈을_import할_수_있어야_한다() {
        #expect(Bool(true))
    }
}
