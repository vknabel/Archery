import Foundation

struct PackageDump: Codable {
    var products: [Product]
}

struct Product: Codable {
    var name: String
    var type: ProductType

    var isExecutable: Bool {
        return type.library == nil
    }

    /**
     * Examples of package dump:
     * - "type": { "executable": null }
     * - "type": { "library": ["automatic"] }
     *
     * Therefore we only load library and check for it
     */
    struct ProductType: Codable {
        var library: [String]?
    }
}

// 0: path to binary
// 1: --package-path
// 2: path/to/package
guard CommandLine.arguments.count > 2, CommandLine.arguments[1] == "--package-path" else {
    print("💥  Must be called with --package-path path")
    exit(1)
}

let packagePath = CommandLine.arguments[2]

let decoder = JSONDecoder()

let output = Pipe()
let process = Process()
process.launchPath = "/usr/bin/env"
process.arguments = ["swift", "package", "--package-path", packagePath, "dump-package"]
process.standardOutput = output
process.launch()
process.waitUntilExit()

let package = try decoder.decode(PackageDump.self, from: output.fileHandleForReading.availableData)

print("scripts:")
for product in package.products where product.isExecutable {
    print("  \(product.name): 'swift run --package-path \(packagePath) \(product.name) $@'")
}
