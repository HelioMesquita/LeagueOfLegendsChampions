import Combine
import Nimble
import Quick

@testable import LeagueOfLegendsChampions

typealias DataCompletion = (Data?, URLResponse?, Error?) -> Void

class ServiceProvider: ServiceProviderProtocol {

    var customURLSession: URLSession

    var urlSession: URLSession {
        return customURLSession
    }

    init(customURLSession: URLSession) {
        self.customURLSession = customURLSession
    }

}

class ServiceProviderProtocolTests: QuickSpec {

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

    var subject: ServiceProviderProtocol!
    var cancellables = Set<AnyCancellable>()
    let builder = ChampionsListBuilder()
    let request = ChampionsRequest(language: "pt_BR", page: 1)
    
    func generateMockURLSession(statusCode: Int = 200, jsonData: Data) -> URLSession {
        let url = try! request.asURLRequest().url!
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        MockURLProtocol.mockURLs = [url: (nil, jsonData, response)]

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: sessionConfiguration)
    }

    override func spec() {
        super.spec()

        describe("#execute") {
            context("when successful request") {
                context("with a correct parser") {
                    it("returns body response parsed") {
                        let mockURLSession = self.generateMockURLSession(jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
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
                                    expect(model.champions.count).to(equal(1))
                                })
                            .store(in: &self.cancellables)
                    }
                }
                context("with a invalid parser") {
                    it("returns a error invalid parser") {
                        let mockURLSession = self.generateMockURLSession(jsonData: self.wrongJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):                                        expect((error)).to(equal(RequestError.invalidParser))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                }
            }
            
            context("when unsuccessful request") {
                context("with known error") {
                    it("returns bad request error") {
                        let mockURLSession = self.generateMockURLSession(statusCode: 400, jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):                                        expect((error)).to(equal(RequestError.badRequest))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                    it("returns unauthorized error") {
                        let mockURLSession = self.generateMockURLSession(statusCode: 401, jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):                                        expect((error)).to(equal(RequestError.unauthorized))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                    it("returns forbidden error") {
                        let mockURLSession = self.generateMockURLSession(statusCode: 403, jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):                                        expect((error)).to(equal(RequestError.forbidden))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                    it("returns not found error") {
                        let mockURLSession = self.generateMockURLSession(statusCode: 404, jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):                                        expect((error)).to(equal(RequestError.notFound))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                    it("returns server error") {
                        let mockURLSession = self.generateMockURLSession(statusCode: 500, jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        expect((error)).to(equal(RequestError.serverError))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                    it("returns unknown error") {
                        let mockURLSession = self.generateMockURLSession(statusCode: 999, jsonData: self.correctJsonData)
                        ServiceProvider(customURLSession: mockURLSession).execute(request: self.request, builder: self.builder)
                            .receive(on: DispatchQueue.main)
                            .sink(
                                receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        expect((error)).to(equal(RequestError.unknownError))
                                    }
                                },
                                receiveValue: { model in
                                    XCTFail()
                                })
                            .store(in: &self.cancellables)
                    }
                }

//                context("with unknown error") {
//                    beforeEach {
//                        self.subject = ServiceProvider(customURLSession: mockURLSession)
//                    }
//
//                    it("returns specific error") {
////                        self.subject.execute(request: MockProvider(), parser: BodyParser.self).done { _ in
//                            XCTFail()
////                        }.catch { error in
////                            expect((error as? RequestError)).to(equal(RequestError.unknownError))
////                        }
//                    }
//                }

            }
        }
    }

}
