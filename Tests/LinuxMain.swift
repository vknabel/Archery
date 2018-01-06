@testable import ArcheryInterfaceTests
@testable import ArcheryKitTests
import XCTest

XCTMain([
    testCase(ArcheryKitTests.allTests),
    testCase(ArcheryInterfaceTests.allTests),
])
