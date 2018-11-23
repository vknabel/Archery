import Foundation

public typealias Script = Annotated<ScriptConvenienceData>

public struct ScriptConvenienceData: Codable {
    public let arrow: String
    public let version: String?
    public let help: String?
    public let env: [String: String]
    public let nestedArrow: Bool?
    public let command: String?

    fileprivate init(
        arrow: String,
        version: String?,
        help: String?,
        env: [String: String],
        nestedArrow: Bool?,
        command: String?
    ) {
        if command == nil && !arrow.contains(" ") && !arrow.starts(with: ".") && arrow.split(separator: "/").count == 2 {
            self.arrow = arrow
            self.command = nil
        } else {
            self.arrow = "vknabel/BashArrow"
            self.command = arrow
        }
        self.version = version
        self.help = help
        self.env = env
        self.nestedArrow = nestedArrow
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: ScriptCodingKey.self) {
            try self.init(
                arrow: container.decode(String.self, forKey: .arrow),
                version: container.decodeIfPresent(String.self, forKey: .version),
                help: container.decodeIfPresent(String.self, forKey: .help),
                env: container.decodeIfPresent([String: String].self, forKey: .env) ?? [:],
                nestedArrow: container.decodeIfPresent(Bool.self, forKey: .nestedArrow),
                command: container.decodeIfPresent(String.self, forKey: .command)
            )
        } else {
            let single = try decoder.singleValueContainer()
            let arrow = try single.decode(String.self)
            self.init(arrow: arrow, version: nil, help: nil, env: [:], nestedArrow: nil, command: nil)
        }
    }
}

fileprivate enum ScriptCodingKey: String, CodingKey {
    case arrow, version, help, env, nestedArrow, command
}

public extension Annotated where V == ScriptConvenienceData {
    public init(
        arrow: String,
        version: String? = nil,
        help: String? = nil,
        env: [String: String] = [:],
        nestedArrow: Bool? = nil,
        command: String? = nil
    ) {
        let scriptData = ScriptConvenienceData(
            arrow: arrow,
            version: version,
            help: help,
            env: env,
            nestedArrow: nestedArrow,
            command: command
        )
        var mutableMetadata: [String: Any] = ["arrow": scriptData.arrow]
        if let help = scriptData.help {
            mutableMetadata["help"] = help
        }
        if let version = scriptData.version {
            mutableMetadata["version"] = version
        }
        if let nestedArrow = scriptData.nestedArrow {
            mutableMetadata["nestedArrow"] = nestedArrow
        }
        if let command = scriptData.command {
            mutableMetadata["command"] = command
        }
        mutableMetadata["env"] = env

        self.init(value: scriptData, by: .init(json: mutableMetadata))
    }

    public var arrow: String {
        return value.arrow
    }

    public var version: String? {
        return value.version
    }

    public var help: String? {
        return value.help
    }

    public var env: [String: String] {
        return value.env
    }

    public var nestedArrow: Bool? {
        return value.nestedArrow
    }

    public var command: String? {
        return value.command
    }
}
