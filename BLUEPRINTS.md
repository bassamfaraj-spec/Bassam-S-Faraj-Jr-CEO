# Blueprints

© 2026 Bassam S Faraj Jr, also known as Bassam Faraj. All rights reserved.

Prepared October 1, 2026. Technical blueprint of the `ExecutiveWorkflowCore` Swift package (per `Package.swift`) and its current source modules. This is a structural reference, not a security certification or proof of production readiness.

## Package blueprint

```mermaid
flowchart TB
    subgraph Package["ExecutiveWorkflowCore (Package.swift, Swift tools 6.0)"]
        direction TB
        subgraph Lib["Library target: ExecutiveWorkflowCore\npath: Sources/ExecutiveWorkflowCore/"]
            M1["EngineScheduler.swift"]
        end
        subgraph Tests["Test target: ExecutiveWorkflowCoreTests\npath: Tests/ExecutiveWorkflowCoreTests/"]
            T1["EngineSchedulerTests.swift"]
        end
    end

    Tests --> Lib

    platforms["Platforms: macOS 14+, iOS 17+\n(declared in Package.swift)"]
    Package --- platforms
```

## Module responsibility blueprint

| Module | Responsibility (inferred from file name / register) |
|---|---|
| `EngineScheduler.swift` | Validates dependency graphs; returns eligible work in release-target/priority order; tracks running and released engines with early/on-time/late results |

## Build blueprint (known-good path)

```mermaid
flowchart LR
    A["swift build / swift test"] -->|Build and scheduler tests pass| B["ExecutiveWorkflowCore\n(Swift package)"]
    C["Xcode framework target"] -->|Not validated here| D["Xcode unavailable in Linux workspace"]
    B -. "not yet wired to" .-> E["Consuming application\n(planned, see ROADMAP.md)"]
```

**Known-good:** `swift build` and `swift test` at the package root succeed on the available Swift 6.4 Linux toolchain. The package declares macOS 14+ and iOS 17+; Apple-platform builds still require Xcode validation.
**Xcode status:** the checked-in Xcode project is not wired to this Swift package. It needs to be integrated and built with Xcode on macOS before Apple-platform readiness can be confirmed.

## Blueprint for next construction phase

1. Integrate the package into the Xcode project and validate the framework/test targets on macOS.
2. Re-run the Xcode scheme build and test plan on macOS.
3. Design and implement the consuming application (daily priorities, delegation, decision follow-up) described in [STORYBOARDS.md](./STORYBOARDS.md).
4. Add persistence, authenticated private sharing, access controls, and integration tests before offering team workspaces.

See [ARCHITECTURE-DIAGRAM.md](./ARCHITECTURE-DIAGRAM.md), [PRODUCT-FOOTPRINT-MAP.md](./PRODUCT-FOOTPRINT-MAP.md), [STORYBOARDS.md](./STORYBOARDS.md), and [ROADMAP.md](./ROADMAP.md).
