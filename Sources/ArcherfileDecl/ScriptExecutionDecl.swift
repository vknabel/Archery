public enum ScriptExecutionDecl: Decodable {
    case bash(command: String)
    case queue(run: [String], scripts: [String: ScriptDecl])
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
                run: literal.enumerated().map { "\($0.offset)" },
                scripts: Dictionary(
                    literal.enumerated().map({ ("\($0.offset)", $0.element) }),
                    uniquingKeysWith: { $1 }
                )
            )
        } else if let object = try? QueueObjectSyntax(from: decoder) {
            self = .queue(run: object.run, scripts: object.scripts)
        } else if let object = try? LegacyObjectSyntax(from: decoder) {
            self = .legacy(arrow: object.arrow, version: object.version, nestedArrow: object.nestedArrow)
        } else {
            fatalError("NO ALTERNATIVES: which exception? \(decoder.codingPath)")
        }
    }
}

private extension ScriptExecutionDecl {
    typealias BashOrLegacyLiteralSyntax = String

    struct BashObjectSyntax: Codable {
        var command: String
    }

    typealias QueueLiteralSyntax = [ScriptDecl]
    struct QueueObjectSyntax: Codable {
        private var mode: QueueMode?
        private var arrow: MigratedArrows?
        var run: [String]
        var scripts: [String: ScriptDecl]

        private enum QueueMode: String, Codable {
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
        !contains(" ") && !starts(with: ".") && split(separator: "/").count == 2
    }
}
