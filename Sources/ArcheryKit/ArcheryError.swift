public enum ArcheryError: Error {
    case undefinedScript(String)
    case couldNotPrepareMetadata
    case invalidScriptDefinition(Any)
    case noArcherfileFound
}
