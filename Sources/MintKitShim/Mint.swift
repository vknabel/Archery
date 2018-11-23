import SwiftCLI

public final class Mint {
    private let path: String
    private let installationPath: String

    public init(path: String, installationPath: String) {
        self.path = path
        self.installationPath = installationPath
    }

    public func run(_ package: Package, arguments: [String], verbose: Bool) throws {
        let verbosity = verbose ? ["--verbose"] : []
        try SwiftCLI.run(
            "mint",
            arguments: ["run"] + verbosity + ["\(package.repo)@\(package.version)", package.name] + arguments,
            directory: nil
        )
    }

    public func capture(_ package: Package, arguments: [String], verbose: Bool, silent: Bool = false) throws -> CaptureResult {
        let silence = silent ? ["--silent"] : []
        let verbosity = verbose ? ["--verbose"] : []
        return try SwiftCLI.capture(
            "mint",
            arguments: ["run"] + silence + verbosity + ["\(package.repo)@\(package.version)", package.name] + arguments,
            directory: nil
        )
    }
}

public struct Package {
    public let repo: String
    public let version: String
    public let name: String

    public init(repo: String, version: String, name: String) {
        self.repo = repo
        self.version = version
        self.name = name
    }
}

public enum MintKit {
    public typealias Mint = MintKitShim.Mint
    public typealias Package = MintKitShim.Package
}
