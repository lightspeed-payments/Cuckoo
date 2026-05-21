import Foundation

enum Attribute: Hashable, CustomStringConvertible {
    case available(arguments: [String])
    case objc
    case objcMembers
    /// A global actor attribute such as `@MainActor`.
    /// The associated `name` does not include the leading `@`.
    case globalActor(name: String)

    var description: String {
        switch self {
        case .available(let arguments):
            "@available(\(arguments.joined(separator: ", ")))"
        case .objc:
            "@objc"
        case .objcMembers:
            "@objcMembers"
        case .globalActor(let name):
            "@\(name)"
        }
    }

    var unavailablePlatform: String? {
        guard case .available(let arguments) = self,
              arguments.count == 2,
              arguments[1] == "unavailable" else {
            return nil
        }

        return String(arguments[0])
    }

    var isGlobalActor: Bool {
        if case .globalActor = self { true } else { false }
    }
}
