import Unbox

public struct Script: Unboxable {
    public let arrow: String
    public let help: String?
    public let metadata: UnboxableDictionary

    public init(arrow: String, help: String? = nil) {
        self.arrow = arrow
        self.help = help

        var mutableMetadata = ["arrow": arrow]
        if let help = help {
            mutableMetadata["help"] = help
        }
        metadata = mutableMetadata
    }

    public init(unboxer: Unboxer) throws {
        arrow = try unboxer.unbox(key: "arrow")
        help = unboxer.unbox(key: "help")
        metadata = unboxer.dictionary
    }
}
