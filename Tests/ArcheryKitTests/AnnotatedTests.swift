//
//  AnnotatedTests.swift
//  ArcheryKitTests
//
//  Created by Valentin Knabel on 21.11.18.
//

import ArcherfileDecl
import ArcheryKit
import XCTest

class AnnotatedTests: XCTestCase {
    func testDecodingComplexMetadata() throws {
        let basic = """
        {
        "scripts": {
        "arrow": "your/Arrow"
        }
        }
        """
        let decoder = JSONDecoder()
        let annotated = try decoder.decode(Annotated<Metadata>.self, from: basic.data(using: .utf8)!)
        XCTAssertEqual(annotated.value, annotated.metadata)
    }

    func testIntializationFromMetadataObject() throws {
        let metadata = Metadata.dictionary(["scripts": .dictionary(["arrow": .string("your/Arrow")])])
        let annotated = try Annotated<Metadata>(metadata: metadata)
        XCTAssertEqual(annotated.value, annotated.metadata)
    }
}
