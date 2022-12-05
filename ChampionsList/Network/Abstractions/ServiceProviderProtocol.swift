import Combine
import Foundation

protocol ServiceProviderProtocol {
    var urlSession: URLSession { get }
    var jsonDecoder: JSONDecoder { get }
    func execute<T>(request: RequestProviderProtocol) -> AnyPublisher<T, RequestError> where T: Decodable
}

extension ServiceProviderProtocol {

    var jsonDecoder: JSONDecoder {
        return JSONDecoder()
    }

    func execute<T>(request: RequestProviderProtocol) -> AnyPublisher<T, RequestError> where T: Decodable {
        return urlSession
            .dataTaskPublisher(for: request.asURLRequest)
            .tryMap { requestData in
                Logger.show(request: request.asURLRequest, requestData)
                guard let httpResponse = requestData.response as? HTTPURLResponse else {
                    throw RequestError.unknownError
                }
                let statusCode = httpResponse.statusCode
                
                if 200...299 ~= statusCode {
                    return requestData.data
                }
                
                throw try identify(statusCode: statusCode)
            }
            .decode(type: T.self, decoder: jsonDecoder)
            .mapError({ value in
                if value is DecodingError {
                    return RequestError.invalidParser
                }
                return value as! RequestError
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    fileprivate func identify(statusCode: Int) throws -> RequestError {
        guard let error = RequestError(rawValue: statusCode) else {
            throw RequestError.unknownError
        }
        throw error
    }

}
