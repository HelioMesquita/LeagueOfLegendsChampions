import Combine
import XCTest

@testable import LeagueOfLegendsChampions

typealias DataCompletion = (Data?, URLResponse?, Error?) -> Void

class ServiceProviderProtocolTests: XCTestCase {

    let correctJsonData = """
        {
          "champions" : [
            {
              "tags" : [
                "Fighter",
                "Tank"
              ],
              "title" : "a Espada Darkin",
              "name" : "Aatrox",
              "image" : "http://ddragon.leagueoflegends.com/cdn/12.22.1/img/champion/Aatrox.png"
            }
          ],
          "hasNextPage" : false,
          "currentPage" : 1
        }
    """.data(using: .utf8)!

    let wrongJsonData = """
        {
          "champions" : [
            {
              "tags" : [
                "Fighter",
                "Tank"
              ],
              "title" : "a Espada Darkin",
              "name" : "Aatrox",
              "image" : "http://ddragon.leagueoflegends.com/cdn/12.22.1/img/champion/Aatrox.png"
            }
          ],
          "hasNextPage" : false,
          "currentPage" : "1"
        }
    """.data(using: .utf8)!

    var mockURLSession: URLSession!
    let builder = ChampionsListBuilder()
    let request = ChampionsRequest(language: "pt_BR", page: 1)
    var cancellables = Set<AnyCancellable>()

    override func tearDownWithError() throws {
        mockURLSession = nil
        try super.tearDownWithError()
    }

    func generateMockURLSession(statusCode: Int = 200, jsonData: Data) {
        let url = try! request.asURLRequest().url!
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        MockURLProtocol.mockURLs = [url: (nil, jsonData, response)]

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: sessionConfiguration)
    }

    func testWhenPerformARequestWithSuccessAndCorrectParserItReturnsMockModel() {
        let expectation = XCTestExpectation()
        generateMockURLSession(jsonData: self.correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        XCTFail()
                    }
                },
                receiveValue: { model in
                    XCTAssertEqual(model.champions.count, 1)
                    expectation.fulfill()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithSuccessAndIncorrectParserItReturnsMockModel() {
        let expectation = XCTestExpectation()
        generateMockURLSession(jsonData: wrongJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.invalidParser)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithUnsuccessWithKnowErrorItReturnsBadRequestError() {
        let expectation = XCTestExpectation()
        generateMockURLSession(statusCode: 400, jsonData: correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.badRequest)
                        expectation.fulfill()

                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithUnsuccessWithKnowErrorItReturnsUnauthorizedError() {
        let expectation = XCTestExpectation()
        generateMockURLSession(statusCode: 401, jsonData: correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.unauthorized)
                        expectation.fulfill()

                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithUnsuccessWithKnowErrorItReturnsForbiddenError() {
        let expectation = XCTestExpectation()
        generateMockURLSession(statusCode: 403, jsonData: correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.forbidden)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithUnsuccessWithKnowErrorItReturnsNotFoundError() {
        let expectation = XCTestExpectation()
        generateMockURLSession(statusCode: 404, jsonData: correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.notFound)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithUnsuccessWithKnowErrorItReturnsServerError() {
        let expectation = XCTestExpectation()
        generateMockURLSession(statusCode: 500, jsonData: correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.serverError)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenPerformARequestWithUnsuccessWithKnowErrorItReturnsUnknownError() {
        let expectation = XCTestExpectation()
        generateMockURLSession(statusCode: 999, jsonData: correctJsonData)
        ServiceProvider(customURLSession: mockURLSession).execute(request: request, builder: builder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTAssertEqual(error, RequestError.unknownError)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail()
                })
            .store(in: &self.cancellables)
        wait(for: [expectation], timeout: 1)
    }

}

class ServiceProvider: ServiceProviderProtocol {

    var customURLSession: URLSession

    var urlSession: URLSession {
        return customURLSession
    }

    init(customURLSession: URLSession) {
        self.customURLSession = customURLSession
    }

}
