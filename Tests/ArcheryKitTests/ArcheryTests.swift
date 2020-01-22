@testable import ArcheryKit
import XCTest

class ArcheryTests: XCTestCase {
    func testLoadsArcherfileFromEnvironmentIfGiven() throws {
        let archery = Archery(environment: [
            "ARCHERY_METADATA": #"{ "version": "1.0.0" }"#,
        ])
        let archerfile = try archery.loadArcherfile(with: [])
        XCTAssertEqual(
            archerfile.metadata,
            Metadata(json: [
                "version": "1.0.0",
                "scripts": [:],
                "loaders": [],
            ])
        )
    }
}
