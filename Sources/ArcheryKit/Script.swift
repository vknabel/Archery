import Unbox

public struct Script: Unboxable {
    public let arrow: String
    public let version: String?
    public let help: String?
    public let env: [String: String]
    public let nestedArrow: Bool?
    public let metadata: UnboxableDictionary

    public init(
        arrow: String,
        version: String? = nil,
        help: String? = nil,
        env: [String: String] = [:],
        nestedArrow: Bool? = nil
    ) {
        self.arrow = arrow
        self.version = version
        self.help = help
        self.env = env
        self.nestedArrow = nestedArrow

        var mutableMetadata: [String: Any] = ["arrow": arrow]
        if let help = help {
            mutableMetadata["help"] = help
        }
        if let version = version {
            mutableMetadata["version"] = version
        }
        if let nestedArrow = nestedArrow {
            mutableMetadata["nestedArrow"] = nestedArrow
        }
        mutableMetadata["env"] = env
        metadata = mutableMetadata
    }

    public init(unboxer: Unboxer) throws {
        arrow = try unboxer.unbox(key: "arrow")
        env = unboxer.unbox(key: "env") ?? [:]
        version = unboxer.unbox(key: "version")
        help = unboxer.unbox(key: "help")
        nestedArrow = unboxer.unbox(key: "nestedArrow")
        metadata = unboxer.dictionary
    }
}
