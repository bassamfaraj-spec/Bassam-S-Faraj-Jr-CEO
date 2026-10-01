import Foundation
import Testing
@testable import ExecutiveWorkflowCore

struct EngineSchedulerTests {
    private let start = Date(timeIntervalSince1970: 1_000)
    private let target = Date(timeIntervalSince1970: 2_000)

    @Test func dependentEngineWaitsForPredecessorRelease() async throws {
        let foundation = EngineWork(id: "foundation", title: "Foundation", plannedStart: start, releaseTarget: target)
        let feature = EngineWork(
            id: "feature",
            title: "Feature",
            plannedStart: start,
            releaseTarget: target,
            dependencies: ["foundation"]
        )
        let scheduler = EngineScheduler(schedule: try EngineSchedule(engines: [foundation, feature]))

        #expect(await scheduler.readyEngines(at: start).map(\.id) == ["foundation"])
        try await scheduler.startEngine("foundation", at: start)
        #expect(await scheduler.readyEngines(at: target).isEmpty)
        _ = try await scheduler.releaseEngine("foundation", at: target)
        #expect(await scheduler.readyEngines(at: target).map(\.id) == ["feature"])
    }

    @Test(arguments: [
        (1_999.0, ReleaseTimeliness.early),
        (2_000.0, ReleaseTimeliness.onTime),
        (2_001.0, ReleaseTimeliness.late),
    ])
    func classifiesReleaseAgainstTarget(timestamp: TimeInterval, expected: ReleaseTimeliness) async throws {
        let engine = EngineWork(id: "engine", title: "Engine", plannedStart: start, releaseTarget: target)
        let scheduler = EngineScheduler(schedule: try EngineSchedule(engines: [engine]))
        try await scheduler.startEngine(engine.id, at: start)

        let result = try await scheduler.releaseEngine(
            engine.id,
            at: Date(timeIntervalSince1970: timestamp)
        )

        #expect(result.timeliness == expected)
    }

    @Test func rejectsMissingDependencies() {
        let engine = EngineWork(
            id: "feature",
            title: "Feature",
            plannedStart: start,
            releaseTarget: target,
            dependencies: ["missing"]
        )

        #expect(throws: EngineScheduleError.missingDependency(engineID: "feature", dependencyID: "missing")) {
            try EngineSchedule(engines: [engine])
        }
    }

    @Test func rejectsDependencyCycles() {
        let first = EngineWork(
            id: "first",
            title: "First",
            plannedStart: start,
            releaseTarget: target,
            dependencies: ["second"]
        )
        let second = EngineWork(
            id: "second",
            title: "Second",
            plannedStart: start,
            releaseTarget: target,
            dependencies: ["first"]
        )

        #expect(throws: EngineScheduleError.self) {
            try EngineSchedule(engines: [first, second])
        }
    }
}
