import XCTest

@testable import LeagueOfLegendsChampions

class RequestErrorTests: XCTestCase {

    func testLocalizedDescription() {
        XCTAssertEqual(RequestError.badRequest.localizedDescription, R.string.localizable.badRequest())
    }

}
