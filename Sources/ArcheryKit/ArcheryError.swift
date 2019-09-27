import Foundation

public enum ArcheryError: Error, CustomStringConvertible {
    case unsupportedScriptSyntax(codingPath: [CodingKey])
    case executionFailed(label: [String], status: Int32)
    case scriptNotFound(name: String, label: [String])

    case archerfileNotFound

    public var description: String {
        switch self {
        case let .unsupportedScriptSyntax(codingPath: path):
            return "Unsupported script syntax at \(path)"
        case .archerfileNotFound:
            return "No Archerfile found"
        case let .executionFailed(label: label, status: status):
            return "\(label.joined(separator: " > ")): failed with \(status)"
        case let .scriptNotFound(name: name, label: label):
            return "\(label.joined(separator: " > ")): could not find \(name)"
        }
    }
}
