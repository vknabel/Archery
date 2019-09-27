import Foundation

public enum ArcheryError: Error, CustomStringConvertible {
    case unsupportedScriptSyntax(codingPath: [CodingKey])
    case executionFailed(label: [String], status: Int32)

    case undefinedScript(String)
    case couldNotPrepareMetadata
    case invalidContentsOfArcherfile
    case invalidScriptDefinition(Any)
    case noArcherfileFound

    public var description: String {
        switch self {
        case let .unsupportedScriptSyntax(codingPath: path):
            return "Unsupported script syntax at \(path)"
        case .invalidContentsOfArcherfile:
            return "Invalid contents of Archerfile"
        case let .undefinedScript(name):
            return "No script named \(name)"
        case .couldNotPrepareMetadata:
            return "Could not prepare metadata"
        case let .invalidScriptDefinition(definition):
            return "Invalid script defintion \(definition)"
        case .noArcherfileFound:
            return "No Archerfile found"
        case let .executionFailed(label: label, status: status):
            return "\(label.joined(separator: " > ")) exited with \(status)"
        }
    }
}
