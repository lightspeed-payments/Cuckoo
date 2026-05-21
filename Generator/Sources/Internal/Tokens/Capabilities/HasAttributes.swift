protocol HasAttributes: Token {
    var attributes: [Attribute] { get }
}

extension HasAttributes {
    private var unavailablePlatforms: [String] {
        attributes.compactMap { $0.unavailablePlatform }
    }

    var hasUnavailablePlatforms: Bool {
        !unavailablePlatforms.isEmpty
    }

    var unavailablePlatformsCheck: String {
        hasUnavailablePlatforms ? "#if !os(\(unavailablePlatforms.joined(separator: ") && !os(")))" : ""
    }

    /// The first global actor attribute applied to this declaration, if any.
    /// Today only `@MainActor` is detected by the Crawler, but more global actors could be added.
    var globalActor: Attribute? {
        attributes.first { $0.isGlobalActor }
    }

    var hasGlobalActor: Bool {
        globalActor != nil
    }

    func attributesSerialize() -> GeneratorContext {
        [
            "attributes": attributes,
        ]
    }
}
