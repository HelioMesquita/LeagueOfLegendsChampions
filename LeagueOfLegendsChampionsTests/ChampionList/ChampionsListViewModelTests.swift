import Combine
import Quick
import Nimble

@testable import LeagueOfLegendsChampions

class ChampionsListViewModelTests: QuickSpec {
    
    var cancellables = Set<AnyCancellable>()
    var mockService: MockChampinsListService!

    override func spec() {
        super.spec()
        
        beforeEach {
            self.mockService = MockChampinsListService()
        }

        describe("#init") {
            it("shoulds do nothing when did not receive a subject") {
                let _ = ChampionsListViewModel(service: self.mockService)
                expect(self.mockService.hasCalled).to(beFalse())
            }
            context("when receive a subject in load state") {
                context("and success a perform request") {
                    it("shoulds perform a loading and returns a model") {
                        let sut = ChampionsListViewModel(service: self.mockService)
                        sut.eventSubject.send(.load)
                        waitUntil { done in
                            switch sut.state {
                            case .loading:
                                expect(true).to(beTrue())
                            case .failureLoading(_):
                                XCTFail()
                            case .success(_):
                                expect(true).to(beTrue())
                                done()
                            }
                        }
                    }
                }
                context("and failure a perform request") {
                    it("shoulds perform a loading and failure state") {
                        let sut = ChampionsListViewModel(service: self.mockService)
                        self.mockService.forceError = true
                        sut.eventSubject.send(.load)
                        waitUntil { done in
                            switch sut.state {
                            case .loading:
                                expect(true).to(beTrue())
                            case .failureLoading(_):
                                expect(true).to(beTrue())
                                done()
                            case .success(_):
                                XCTFail()
                            }
                        }
                    }
                }
            }
        }
    }

}

class MockChampinsListService: ChampionsServiceProtocol {
    
    var hasCalled = false
    var forceError = false
    
    func getChampionsList(page: Int, language: String) -> AnyPublisher<LeagueOfLegendsChampions.ChampionsListBuilder.Model, LeagueOfLegendsChampions.RequestError> {
        hasCalled = true
 
        let mockModel = LeagueOfLegendsChampions.ChampionsListBuilder.Model(champions: [], currentPage: 1, hasNextPage: true)
        let valueChangedSubject = PassthroughSubject<LeagueOfLegendsChampions.ChampionsListBuilder.Model,
                                                                  LeagueOfLegendsChampions.RequestError>()
        if forceError {
            valueChangedSubject.send(completion: .failure(RequestError.unknownError))
        } else {
            valueChangedSubject.send(mockModel)
        }
        
        
        return valueChangedSubject.eraseToAnyPublisher()
    }
    
    
}
