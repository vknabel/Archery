import Foundation

struct PackageJSON: Codable {
    var scripts: [String: String]
}

// 0: path to binary
// 1: path to package.json
// 2: maybe --yarn
let usesYarn = CommandLine.arguments.contains("--yarn")
let decoder = JSONDecoder()
let package = try decoder.decode(PackageJSON.self, from: Data(contentsOf: URL(fileURLWithPath: "package.json")))

print("scripts:")
for (name, _) in package.scripts {
    print("  \(name): '\(usesYarn ? "yarn" : "npm run") \(name) $@'")
}
