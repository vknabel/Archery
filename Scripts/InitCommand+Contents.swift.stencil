import Foundation.NSString

extension InitCommand {
    func archerfileContents(name: String) -> String {
        return """
        {
            "name": "\(name)",
            "version": "1.0.0",
            "scripts": {
                "xcopen": {
                    "arrow": "vknabel/BashArrow",
                    "command": "swift package generate-xcodeproj && open \(name).xcodeproj"
                }
            }
        }
        """
    }
}
