import Foundation

class ListBuilder: BuilderProviderProtocol {
    
    func build(response: ListBuilder.Response) throws -> ListBuilder.Model {
        let championsModel = response.champions.compactMap({ Model.ChampionModel(name: $0.name, image: $0.image, tags: $0.tags, title: $0.title) })
        
        return Model(champions: championsModel, currentPage: response.currentPage, hasNextPage: response.hasNextPage)
    }

}

extension ListBuilder {
    struct Response: Decodable {
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
    
    struct Model {
        let champions: [ChampionModel]
        let currentPage: Int
        let hasNextPage: Bool
        
        struct ChampionModel: Hashable {
            let name: String
            let image: URL
            let tags: [String]
            let title: String
        }
    }

}
