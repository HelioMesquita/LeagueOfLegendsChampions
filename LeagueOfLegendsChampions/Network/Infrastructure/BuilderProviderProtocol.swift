import Foundation

protocol BuilderProviderProtocol {

    associatedtype ResponseType: Decodable
    associatedtype ModelType

    func build(response: ResponseType) throws -> ModelType
}
