import Foundation

struct ListResponse: Decodable {
    let champions: [Champion]
    let currentPage: Int
    let hasNextPage: Bool
    
    struct Champion: Decodable {
        let name: String
        let image: URL
        let tags: [String]
        let title: String
    }
}
