import XCTest
@testable import TandemImport

final class PersonalDefaultsTests: XCTestCase {
    func testFilmoraDoesNotRewriteAnotherUsersHomeByDefault() {
        XCTAssertTrue(FilmoraImporter().locating.pathRewrites.isEmpty)
    }
}
