import Foundation

class ServiceProvider: ServiceProviderProtocol {

    var urlSession: URLSession {
        return URLSession.shared
    }

    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

}
