import XCTest
import Cuckoo
@testable import CuckooMocks

@MainActor
final class MainActorProtocolTest: XCTestCase {

    func testGreet() {
        let mock = MockMainActorProtocol()
        stub(mock) { mock in
            when(mock.greet(name: anyString())).thenReturn("Hello, World!")
        }

        XCTAssertEqual(mock.greet(name: "World"), "Hello, World!")
        verify(mock).greet(name: equal(to: "World"))
    }

    func testReadWriteProperty() {
        let mock = MockMainActorProtocol()
        stub(mock) { mock in
            when(mock.greeting.get).thenReturn("Bonjour")
            when(mock.greeting.set(anyString())).thenDoNothing()
        }

        XCTAssertEqual(mock.greeting, "Bonjour")
        mock.greeting = "Hi"
        verify(mock).greeting.get()
        verify(mock).greeting.set(equal(to: "Hi"))
    }

    func testThrowingMethod() throws {
        let mock = MockMainActorProtocol()
        stub(mock) { mock in
            when(mock.mayThrow()).thenReturn("ok")
        }

        XCTAssertEqual(try mock.mayThrow(), "ok")
        verify(mock).mayThrow()
    }

    func testAsyncMethod() async {
        let mock = MockMainActorProtocol()
        stub(mock) { mock in
            when(mock.compute(value: anyInt())).thenReturn(42)
        }

        let result = await mock.compute(value: 21)
        XCTAssertEqual(result, 42)
        verify(mock).compute(value: equal(to: 21))
    }

    func testAsyncThrowingMethod() async throws {
        let mock = MockMainActorProtocol()
        stub(mock) { mock in
            when(mock.mayThrowAsync()).thenReturn("ok-async")
        }

        let result = try await mock.mayThrowAsync()
        XCTAssertEqual(result, "ok-async")
        verify(mock).mayThrowAsync()
    }

    func testEnableDefaultImplementation() {
        let mock = MockMainActorProtocol()
        let defaultImpl = MainActorProtocolDefaultImpl()
        defaultImpl.greeting = "Hola"
        mock.enableDefaultImplementation(defaultImpl)

        // The mock should fall through to the default implementation when not stubbed.
        XCTAssertEqual(mock.greet(name: "Mundo"), "Hola, Mundo!")
    }

    func testStubClassExists() {
        // Ensures the no-op stub class is also @MainActor and conforms to the protocol.
        let stub: any MainActorProtocol = MainActorProtocolStub()
        // Reading a non-stubbed value returns the default registered value (an empty string).
        _ = stub.greeting
    }

    func testMixedIsolationMockAvailable() {
        // The mixed protocol is *not* @MainActor at the type level, but one of its methods is.
        // The generated mock should be usable from a non-isolated context for the non-isolated method.
        // Here we exercise it from MainActor context for simplicity.
        let mock = MockMixedActorIsolationProtocol()
        stub(mock) { mock in
            when(mock.nonIsolated(value: anyInt())).thenReturn(7)
            when(mock.mainActorOnly(name: anyString())).thenReturn("hi")
        }

        XCTAssertEqual(mock.nonIsolated(value: 1), 7)
        XCTAssertEqual(mock.mainActorOnly(name: "x"), "hi")
        verify(mock).nonIsolated(value: equal(to: 1))
        verify(mock).mainActorOnly(name: equal(to: "x"))
    }
}
