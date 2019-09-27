import XCTest

import ArcheryInterfaceTests
import ArcheryKitTests

var tests = [XCTestCaseEntry]()
tests += ArcheryInterfaceTests.__allTests()
tests += ArcheryKitTests.__allTests()

XCTMain(tests)
