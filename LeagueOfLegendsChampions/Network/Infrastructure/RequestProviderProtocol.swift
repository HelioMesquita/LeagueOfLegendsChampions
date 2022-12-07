import Foundation

protocol RequestProviderProtocol {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var bodyParameters: Encodable? { get }
    var queryParameters: [URLQueryItem]? { get }
    var headers: [String: String] { get }
    var httpVerb: HttpVerbs { get }
    func asURLRequest() throws -> URLRequest
}

extension RequestProviderProtocol {
    
    var scheme: String {
        return Bundle.main.scheme
    }

    var host: String {
        return Bundle.main.host
    }

    var bodyParameters: Encodable? {
        return nil
    }

    var queryParameters: [URLQueryItem]? {
        return nil
    }

    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }

    func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryParameters
        
        guard let url = components.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpVerb.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        if let bodyParameters = bodyParameters, let data = bodyParameters.toJSONData() {
            request.httpBody = data
        }

        return request
    }

}

private extension Encodable {

    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }

}
