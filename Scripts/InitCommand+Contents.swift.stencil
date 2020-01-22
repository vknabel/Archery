extension InitCommand {
    func archerfileContents(name: String) -> String {
        return """
        name: \(name)
        version: 1.0.0
        scripts:
          xcopen: swift package generate-xcodeproj && xed .

        """
    }
}
