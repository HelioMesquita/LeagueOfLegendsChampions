import Combine
import Foundation

protocol ServiceProviderProtocol {
    var urlSession: URLSession { get }
    var jsonDecoder: JSONDecoder { get }
    func execute<BuilderType: BuilderProviderProtocol>(request: RequestProviderProtocol, builder: BuilderType) -> AnyPublisher<BuilderType.ModelType, RequestError>
}

extension ServiceProviderProtocol {

    var jsonDecoder: JSONDecoder {
        return JSONDecoder()
    }
    
    func execute<BuilderType: BuilderProviderProtocol>(request: RequestProviderProtocol, builder: BuilderType) -> AnyPublisher<BuilderType.ModelType, RequestError> {
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
                } else {
                    throw try identify(statusCode: statusCode)
                }
            }
            .decode(type: BuilderType.ResponseType.self, decoder: jsonDecoder)
            .tryMap({ try builder.build(response: $0) })
            .mapError({ genericError in
                if let error = genericError as? RequestError {
                    return error
                } else if let error  = genericError as? URLError {
                    return .internetError
                } else {
                    return RequestError.invalidParser
                }
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
