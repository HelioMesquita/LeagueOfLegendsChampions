import XCTest

@testable import LeagueOfLegendsChampions

class RequestProviderProtocolTests: XCTestCase {

    var sut: RequestProviderProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockProvider()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testURLRequestMethodItReturnsACorrectURLWithQueryParameters() {
        let urlString = try? sut.asURLRequest().url?.absoluteString
        XCTAssertEqual(urlString, "https://google.host/testando?key=value")
    }

    func testURLRequestMethodItReturnsAllHeaders() {
        let headers = try? sut.asURLRequest().allHTTPHeaderFields
        XCTAssertEqual(headers, ["Content-Type": "application/json"])
    }

    func testURLRequestMethodItReturnsHttbBodyData() {
        let httpBody = try? sut.asURLRequest().httpBody
        XCTAssertNotNil(httpBody)
    }

}
