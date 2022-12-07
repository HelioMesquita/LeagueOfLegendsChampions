import Foundation

@testable import LeagueOfLegendsChampions

class MockProvider: RequestProviderProtocol {

    struct Endoder: Encodable {
        let body: String = "body"
    }

    var path: String {
        return "/testando"
    }

    var httpVerb: HttpVerbs {
        return .GET
    }

    var scheme: String {
        return "https"
    }

    var host: String {
        return "google.host"
    }

    var bodyParameters: Encodable? {
        return Endoder()
    }

    var queryParameters: [URLQueryItem]? {
        return [URLQueryItem(name: "key", value: "value")]
    }

    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }

}
