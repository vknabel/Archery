public enum ScriptExecution: Decodable {
    case bash(command: String)
    case queue(run: [String], scripts: [String: Script])
    case legacy(arrow: String, version: String?, nestedArrow: Bool?)

    public var metadata: Metadata {
        switch self {
        case let .bash(command: command):
            return .dictionary(["command": .string(command)])
        case let .queue(run: run, scripts: scripts):
            return .dictionary(["run": .array(run.map(Metadata.string)), "scripts": .dictionary(scripts.mapValues { $0.metadata })])
        case let .legacy(arrow: arrow, version: version, nestedArrow: nestedArrow):
            return .dictionary(["arrow": .string(arrow), "version": version.map(Metadata.string) ?? Metadata.null, "nestedArrow": nestedArrow.map(Metadata.boolean) ?? Metadata.null])
        }
    }

    public init(from decoder: Decoder) throws {
        if let literal = try? BashOrLegacyLiteralSyntax(from: decoder) {
            self = literal.isLegacyLiteral
                ? .legacy(arrow: literal, version: nil, nestedArrow: nil)
                : .bash(command: literal)
        } else if let object = try? BashObjectSyntax(from: decoder) {
            self = .bash(command: object.command)
        } else if let literal = try? QueueLiteralSyntax(from: decoder) {
            self = .queue(
                run: literal.enumerated().map { "step \($0.offset)" },
                scripts: Dictionary(
                    literal.enumerated().map({ ("step \($0.offset)", $0.element) }),
                    uniquingKeysWith: { $1 }
                )
            )
        } else if let object = try? QueueObjectSyntax(from: decoder) {
            self = .queue(run: object.run, scripts: object.scripts)
        } else if let object = try? LegacyObjectSyntax(from: decoder) {
            self = .legacy(arrow: object.arrow, version: object.version, nestedArrow: object.nestedArrow)
        } else {
            throw ArcheryError.unsupportedScriptSyntax(codingPath: decoder.codingPath)
        }
    }

    public var bashCommand: String? {
        if case let .bash(command) = self {
            return (command)
        } else {
            return nil
        }
    }

    public var queue: (run: [String], scripts: [String: Script])? {
        if case let .queue(run, scripts) = self {
            return (run, scripts)
        } else {
            return nil
        }
    }

    public var legacy: (arrow: String, version: String?, nestedArrow: Bool?)? {
        if case let .legacy(arrow, version, nestedArrow) = self {
            return (arrow, version, nestedArrow)
        } else {
            return nil
        }
    }
}

private extension ScriptExecution {
    typealias BashOrLegacyLiteralSyntax = String

    struct BashObjectSyntax: Codable {
        var command: String
    }

    typealias QueueLiteralSyntax = [Script]
    struct QueueObjectSyntax: Codable {
        private var type: QueueType?
        private var arrow: MigratedArrows?
        var run: [String]
        var scripts: [String: Script]

        private enum QueueType: String, Codable {
            case queue
        }

        private enum MigratedArrows: String, Codable {
            case archeryArrow = "vknabel/ArcheryArrow"
        }
    }

    struct LegacyObjectSyntax: Codable {
        public var arrow: String
        public var version: String?
        public var nestedArrow: Bool?
    }
}

private extension String {
    var isLegacyLiteral: Bool {
        return !contains(" ") && !starts(with: ".") && split(separator: "/").count == 2
    }
}
