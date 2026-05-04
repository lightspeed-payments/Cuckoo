import Foundation

/// A protocol annotated with `@MainActor` at the type level. The generated mock
/// must also be `@MainActor` to satisfy the protocol's isolation requirements.
@MainActor
protocol MainActorProtocol {
    var greeting: String { get set }

    func greet(name: String) -> String

    func compute(value: Int) async -> Int

    func mayThrow() throws -> String

    func mayThrowAsync() async throws -> String
}

/// A non-isolated protocol with a single `@MainActor`-annotated method. Only that
/// method on the generated mock should carry `@MainActor`; the type itself stays
/// non-isolated.
protocol MixedActorIsolationProtocol {
    func nonIsolated(value: Int) -> Int

    @MainActor
    func mainActorOnly(name: String) -> String
}

/// A simple `@MainActor`-isolated default implementation used to verify
/// `enableDefaultImplementation(_:)` works for `@MainActor` mocks.
@MainActor
final class MainActorProtocolDefaultImpl: MainActorProtocol {
    var greeting: String = "Hello"

    func greet(name: String) -> String {
        "\(greeting), \(name)!"
    }

    func compute(value: Int) async -> Int {
        value * 2
    }

    func mayThrow() throws -> String {
        "ok"
    }

    func mayThrowAsync() async throws -> String {
        "ok-async"
    }
}
