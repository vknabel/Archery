typealias LabeledScript = (label: [String], script: Script)

extension Script {
    func labeled(by label: [String]) -> LabeledScript {
        return (label, self)
    }
}
