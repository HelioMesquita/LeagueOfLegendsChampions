import Foundation

class ListProvider: RequestProviderProtocol {

    var httpVerb: HttpVerbs = .GET
    var path: String = "/champions"
    let page: Int
    let language: String

    var queryParameters: [URLQueryItem]? {
        return [
            URLQueryItem(name: "language", value: language.replacingOccurrences(of: "-", with: "_")),
            URLQueryItem(name: "page", value: "\(page)")
        ]
    }

    init(language: String, page: Int) {
        self.language = language
        self.page = page
    }

}
