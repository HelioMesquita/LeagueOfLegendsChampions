import Foundation

enum RequestError: Int, Error, LocalizedError {

    typealias RawValue = Int

    case unknownError = 0
    case invalidParser = 1
    case internetError = 2
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case serverError = 500

    var localizedDescription: String {
        return NSLocalizedString(String(describing: self.rawValue), comment: "")
    }

}
