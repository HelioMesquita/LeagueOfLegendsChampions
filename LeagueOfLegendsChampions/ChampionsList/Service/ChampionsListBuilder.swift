import Foundation

class ChampionsListBuilder: BuilderProviderProtocol {
    
    func build(response: ChampionsListBuilder.Response) throws -> ChampionsListBuilder.Model {
        let championsModel = response.champions
            .compactMap({ Model.ChampionModel(name: $0.name,
                                              image: $0.image,
                                              tags: $0.tags) })
        
        return Model(champions: championsModel,
                     currentPage: response.currentPage,
                     hasNextPage: response.hasNextPage)
    }

}

extension ChampionsListBuilder {
    struct Response: Decodable {
        let champions: [Champion]
        let currentPage: Int
        let hasNextPage: Bool
        
        struct Champion: Decodable {
            let name: String
            let image: URL
            let tags: [String]
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
        }

        func updateModel(_ model: Model) -> Model {
            Model(champions: self.champions + model.champions,
                  currentPage:model.currentPage,
                  hasNextPage: model.hasNextPage)
        }
    }

}
