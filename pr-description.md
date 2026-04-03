### Summary
Adds a new `CuckooPluginModular` build tool plugin that generates separate mock files per module dependency, improving modularity for multi-target Swift Packages.

Related issue: https://github.com/Brightify/Cuckoo/issues/555

### Motivation
The existing `CuckooPluginSingleFile` generates all mocks into a single `GeneratedMocks.swift` file in derived data. In a Swift Package with multiple targets, each test target compiles independently and may not have visibility into types from unrelated modules, making a single shared mock file problematic.

### Changes

#### New Plugin: CuckooPluginModular

- Located in `Generator/Plugin/Modular/`
- Inspects the test target's dependencies (excluding Cuckoo) and runs the generator once per dependency module
- Each module gets its own build command with `CUCKOO_MODULE_NAME` environment variable
- Generates one mock file per module: `GeneratedMocks_<ModuleName>.swift`
- Also emits a build command keyed by the test target's own name, aggregating all dependency sources — this allows `Cuckoofile.toml` to have a `[modules.<TestTargetName>]` entry to control which files are mocked and which imports are added
- A `Cuckoofile.toml` entry is required for each module; modules without a matching entry produce an empty file

### Usage

**Package.swift:**
```swift
.testTarget(
    name: "TargetATests",
    dependencies: ["TargetA", "Cuckoo"],
    plugins: [
        .plugin(name: "CuckooPluginModular", package: "Cuckoo"),
    ]
),
.testTarget(
    name: "AggregationTargetTests",
    dependencies: ["AggregationTarget", "Cuckoo"],
    plugins: [
        .plugin(name: "CuckooPluginModular", package: "Cuckoo"),
    ]
)
```

**Cuckoofile.toml:**
```toml
# TargetA mocks
[modules.TargetATests]
imports = ["Foundation"]
testableImports = ["TargetA"]
sources = [
    "Sources/TargetA/InternalProtocolA.swift"
]

# AggregationTarget mocks - multiple imports
[modules.AggregationTargetTests]
imports = ["Foundation", "TargetA", "TargetB"]
sources = [
    "Sources/TargetA/ProtocolA.swift",
    "Sources/TargetB/ProtocolB.swift",
]
```

### Breaking Changes
None. All changes are backward compatible with existing plugins and configurations.
