import Unbox

public struct Script: Unboxable {
    public let arrow: String
    public let version: String?
    public let help: String?
    public let metadata: UnboxableDictionary

    public init(arrow: String, version: String? = nil, help: String? = nil) {
        self.arrow = arrow
        self.version = version
        self.help = help

        var mutableMetadata = ["arrow": arrow]
        if let help = help {
            mutableMetadata["help"] = help
        }
        if let version = version {
            mutableMetadata["version"] = version
        }
        metadata = mutableMetadata
    }

    public init(unboxer: Unboxer) throws {
        arrow = try unboxer.unbox(key: "arrow")
        version = unboxer.unbox(key: "version")
        help = unboxer.unbox(key: "help")
        metadata = unboxer.dictionary
    }
}
