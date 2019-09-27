import Yams

public extension Metadata {
    init(string: String) throws {
        self = try Yams.YAMLDecoder().decode(Metadata.self, from: string)
    }
}
