import Foundation

protocol BuilderProviderProtocol {
    
    associatedtype ResponseType: Decodable
    associatedtype ModelType
    
    func build(response: ResponseType) throws -> ModelType
}

extension BuilderProviderProtocol {
    
    func build(response: Decodable) throws -> ModelType {
        throw NSError(domain: "missing implementation", code: 0)
    }
}
