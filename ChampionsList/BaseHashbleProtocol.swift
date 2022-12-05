import Foundation

protocol BaseHashbleProtocol: Hashable {
    var id: String { get }

    func hash(into hasher: inout Hasher)
}

extension BaseHashbleProtocol {

    var id: String {
        return UUID().uuidString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

}
