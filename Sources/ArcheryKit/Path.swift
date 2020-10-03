import Foundation

public struct Path: Hashable, ExpressibleByStringLiteral {
    public private(set) var string: String

    public init(_ string: String) {
        self.string = string
    }

    public init(stringLiteral string: String) {
        self.init(string)
    }

    public static var current: Path {
        Path(FileManager.default.currentDirectoryPath)
    }

    public func read() throws -> String {
        try String(contentsOfFile: string)
    }

    public func write(
        _ contents: String,
        automatically: Bool = true,
        encoding: String.Encoding = .utf8
    ) throws {
        try contents.write(toFile: string, atomically: automatically, encoding: encoding)
    }

    public func normalize() -> Path {
        Path((string as NSString).standardizingPath)
    }

    public func absolute() -> Path {
        if string.starts(with: "/") || string.starts(with: "~") {
            return self
        } else {
            return Path.current + self
        }
    }

    public var lastComponentWithoutExtension: String {
        (string as NSString).deletingPathExtension
    }
}

public func + (lhs: Path, rhs: Path) -> Path {
    Path((lhs.string as NSString).appendingPathComponent(rhs.string))
}
