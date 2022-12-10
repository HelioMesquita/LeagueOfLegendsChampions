import Combine
import XCTest

@testable import LeagueOfLegendsChampions

class ChampionsListViewModelTests: XCTestCase {

    var mockService: MockChampinsListService!
    var sut: ChampionsListViewModel!
    var cancellables: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockService = MockChampinsListService()
        sut = ChampionsListViewModel(service: mockService)
    }

    override func tearDownWithError() throws {
        mockService = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenViewControllerStartToObsverveItReturnsLoadingState() {
        let expectation = XCTestExpectation(description: "Start to be observable")

        sut.$state.sink { state in
            XCTAssertEqual(state, .loading)
            expectation.fulfill()
        }.store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testWhenViewControllerSendLoadEventAndItReturnsSuccessState() {
        let expectation = XCTestExpectation(description: "Request successfully")
        let mockModel = ChampionsListBuilder.Model(champions: [], currentPage: 1, hasNextPage: true)

        sut.$state.dropFirst().sink { state in
            XCTAssertEqual(state, .success(mockModel))
            expectation.fulfill()
        }.store(in: &cancellables)

        mockService.mockResult = Result.success(mockModel).publisher.eraseToAnyPublisher()
        sut.eventSubject.send(.load)
        XCTAssertEqual(mockService.pageLoading, 1)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenViewControllerSendLoadEventAndItReturnsFailureState() {
        let expectation = XCTestExpectation(description: "Request failed")

        sut.$state.dropFirst().sink { state in
            XCTAssertEqual(state, .failure(RequestError.unknownError))
            expectation.fulfill()
        }.store(in: &cancellables)

        mockService.mockResult = Result.failure(RequestError.unknownError).publisher.eraseToAnyPublisher()
        sut.eventSubject.send(.load)
        XCTAssertEqual(mockService.pageLoading, 1)
        wait(for: [expectation], timeout: 1)
    }

    func testWhenViewControllerSendPrefetchNextPageAndHasNextPageItReturnsCurrentPagePlusOne() {
        let expectation = XCTestExpectation(description: "Request successfully")
        let mockModel = ChampionsListBuilder.Model(champions: [
            ChampionsListBuilder.Model.ChampionModel(name: "Test", image: URL(string: "www.google.com.br")!,
                                                     tags: [])],
                                                   currentPage: 1, hasNextPage: true)
        mockService.mockResult = Result.success(mockModel).publisher.eraseToAnyPublisher()
        sut.eventSubject.send(.load)

        sut.$state.dropFirst().first().sink { state in
            switch state {
            case .loading:
                break
            case .failure(_):
                break
            case .success(_):
                self.sut.eventSubject.send(.prefetchNextPage(index: 0))
                self.sut.$state.dropFirst().sink { _ in
                    XCTAssertEqual(self.mockService.pageLoading, 2)
                    expectation.fulfill()
                }.store(in: &self.cancellables)
            }
        }.store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
    }

}

class MockChampinsListService: ChampionsServiceProtocol {

    var mockResult: AnyPublisher<LeagueOfLegendsChampions.ChampionsListBuilder.Model, LeagueOfLegendsChampions.RequestError>!
    var pageLoading: Int!

    func getChampionsList(page: Int, language: String) -> AnyPublisher<LeagueOfLegendsChampions.ChampionsListBuilder.Model, LeagueOfLegendsChampions.RequestError> {
        pageLoading = page
        return mockResult
    }

}
