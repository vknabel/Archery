public struct ScriptDecl: Codable, OfferingMetadata {
    public var execution: ScriptExecutionDecl
    public var help: String?
    public var env: [String: String]?

    public var metadata: Metadata

    public init(from decoder: Decoder) throws {
        execution = try ScriptExecutionDecl(from: decoder)

        let details = try? ExecutionDetailsSyntax(from: decoder)
        help = details?.help
        env = details?.env

        metadata = try Metadata(from: decoder)
            .appending(using: execution.metadata)
    }

    public func encode(to encoder: Encoder) throws {
        try metadata.encode(to: encoder)
    }

    private struct ExecutionDetailsSyntax: Codable {
        var help: String?
        var env: [String: String]?
    }
}
