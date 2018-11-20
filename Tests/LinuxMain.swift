// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

@testable import ArcheryInterfaceTests
@testable import ArcheryKitTests
import XCTest

extension ArcherfileParsing {
    static var allTests: [(String, (ArcherfileParsing) -> () throws -> Void)] = [
        ("testArcherfileParsingFromMinimalFile", testArcherfileParsingFromMinimalFile),
        ("testArcherfileParsingFromEmptyScripts", testArcherfileParsingFromEmptyScripts),
        ("testArcherfileParsingFailsFromScriptsArray", testArcherfileParsingFailsFromScriptsArray),
        ("testArcherfileParsingFromSomeScripts", testArcherfileParsingFromSomeScripts),
        ("testArcherfileParsingFromSomeScriptsAndShorthand", testArcherfileParsingFromSomeScriptsAndShorthand),
    ]
}

extension ArcheryInterfaceTests {
    static var allTests: [(String, (ArcheryInterfaceTests) -> () throws -> Void)] = [
        ("testExample", testExample),
    ]
}

extension ArcheryKitTests {
    static var allTests: [(String, (ArcheryKitTests) -> () throws -> Void)] = [
        ("testExample", testExample),
    ]
}

extension ScriptParsingTests {
    static var allTests: [(String, (ScriptParsingTests) -> () throws -> Void)] = [
        ("testScriptParsingFromMinimalArrow", testScriptParsingFromMinimalArrow),
        ("testScriptParsingFailsFromMinimalArrowWithComplexRepo", testScriptParsingFailsFromMinimalArrowWithComplexRepo),
        ("testScriptParsingFromFullScript", testScriptParsingFromFullScript),
        ("testScriptParsingFromFullScriptIncludingMetadata", testScriptParsingFromFullScriptIncludingMetadata),
        ("testScriptFromInitializer", testScriptFromInitializer),
    ]
}

// swiftlint:disable trailing_comma
XCTMain([
    testCase(ArcherfileParsing.allTests),
    testCase(ArcheryInterfaceTests.allTests),
    testCase(ArcheryKitTests.allTests),
    testCase(ScriptParsingTests.allTests),
])
// swiftlint:enable trailing_comma
