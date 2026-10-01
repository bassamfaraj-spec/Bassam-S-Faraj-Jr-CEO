import Foundation

public struct EngineWork: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let plannedStart: Date
    public let releaseTarget: Date
    public let dependencies: Set<String>
    public let priority: Int

    public init(
        id: String,
        title: String,
        plannedStart: Date,
        releaseTarget: Date,
        dependencies: Set<String> = [],
        priority: Int = 0
    ) {
        self.id = id
        self.title = title
        self.plannedStart = plannedStart
        self.releaseTarget = releaseTarget
        self.dependencies = dependencies
        self.priority = priority
    }
}

public enum EngineState: Equatable, Sendable {
    case queued
    case running(startedAt: Date)
    case released(at: Date)
}

public enum ReleaseTimeliness: Equatable, Sendable {
    case early
    case onTime
    case late
}

public struct ReleaseResult: Equatable, Sendable {
    public let work: EngineWork
    public let releasedAt: Date
    public let timeliness: ReleaseTimeliness
}

public enum EngineScheduleError: Error, Equatable, Sendable {
    case duplicateID(String)
    case missingDependency(engineID: String, dependencyID: String)
    case cyclicDependency(String)
    case invalidWindow(String)
    case unknownEngine(String)
    case notReady(String)
    case alreadyRunning(String)
    case alreadyReleased(String)
    case notRunning(String)
    case releaseBeforeStart(String)
}

public struct EngineSchedule: Sendable {
    public let engines: [EngineWork]

    public init(engines: [EngineWork]) throws {
        var enginesByID: [String: EngineWork] = [:]

        for engine in engines {
            guard enginesByID[engine.id] == nil else {
                throw EngineScheduleError.duplicateID(engine.id)
            }
            guard engine.plannedStart <= engine.releaseTarget else {
                throw EngineScheduleError.invalidWindow(engine.id)
            }
            enginesByID[engine.id] = engine
        }

        for engine in engines {
            for dependencyID in engine.dependencies {
                guard enginesByID[dependencyID] != nil else {
                    throw EngineScheduleError.missingDependency(
                        engineID: engine.id,
                        dependencyID: dependencyID
                    )
                }
            }
        }

        var visiting = Set<String>()
        var visited = Set<String>()

        func visit(_ id: String) throws {
            if visited.contains(id) { return }
            guard visiting.insert(id).inserted else {
                throw EngineScheduleError.cyclicDependency(id)
            }

            for dependencyID in enginesByID[id, default: engines[0]].dependencies {
                try visit(dependencyID)
            }

            visiting.remove(id)
            visited.insert(id)
        }

        for engine in engines {
            try visit(engine.id)
        }

        self.engines = engines
    }
}

public actor EngineScheduler {
    private let schedule: EngineSchedule
    private let enginesByID: [String: EngineWork]
    private var states: [String: EngineState]

    public init(schedule: EngineSchedule) {
        self.schedule = schedule
        self.enginesByID = Dictionary(uniqueKeysWithValues: schedule.engines.map { ($0.id, $0) })
        self.states = Dictionary(uniqueKeysWithValues: schedule.engines.map { ($0.id, .queued) })
    }

    public func state(for engineID: String) throws -> EngineState {
        guard let state = states[engineID] else {
            throw EngineScheduleError.unknownEngine(engineID)
        }
        return state
    }

    public func readyEngines(at date: Date) -> [EngineWork] {
        schedule.engines
            .filter { engine in
                guard engine.plannedStart <= date, states[engine.id] == .queued else {
                    return false
                }
                return engine.dependencies.allSatisfy { dependencyID in
                    if case .released? = states[dependencyID] { return true }
                    return false
                }
            }
            .sorted {
                if $0.releaseTarget != $1.releaseTarget {
                    return $0.releaseTarget < $1.releaseTarget
                }
                if $0.priority != $1.priority {
                    return $0.priority > $1.priority
                }
                return $0.id < $1.id
            }
    }

    public func startEngine(_ engineID: String, at date: Date) throws {
        guard let engine = enginesByID[engineID], let state = states[engineID] else {
            throw EngineScheduleError.unknownEngine(engineID)
        }
        switch state {
        case .running:
            throw EngineScheduleError.alreadyRunning(engineID)
        case .released:
            throw EngineScheduleError.alreadyReleased(engineID)
        case .queued:
            guard readyEngines(at: date).contains(where: { $0.id == engineID }) else {
                throw EngineScheduleError.notReady(engineID)
            }
            states[engineID] = .running(startedAt: date)
        }
    }

    public func releaseEngine(_ engineID: String, at date: Date) throws -> ReleaseResult {
        guard let engine = enginesByID[engineID], let state = states[engineID] else {
            throw EngineScheduleError.unknownEngine(engineID)
        }
        guard case let .running(startedAt) = state else {
            if case .released = state {
                throw EngineScheduleError.alreadyReleased(engineID)
            }
            throw EngineScheduleError.notRunning(engineID)
        }
        guard date >= startedAt else {
            throw EngineScheduleError.releaseBeforeStart(engineID)
        }

        let timeliness: ReleaseTimeliness
        if date < engine.releaseTarget {
            timeliness = .early
        } else if date == engine.releaseTarget {
            timeliness = .onTime
        } else {
            timeliness = .late
        }

        states[engineID] = .released(at: date)
        return ReleaseResult(work: engine, releasedAt: date, timeliness: timeliness)
    }
}
