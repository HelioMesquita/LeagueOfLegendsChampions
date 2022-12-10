import Combine
import UIKit

protocol ChampionsServiceProtocol {
    func getChampionsList(page: Int, language: String) -> AnyPublisher<ChampionsListBuilder.Model, RequestError>
}

class ChampionsService: ChampionsServiceProtocol {

    private let serviceProvider: ServiceProviderProtocol

    init(serviceProvider: ServiceProviderProtocol = ServiceProvider()) {
        self.serviceProvider = serviceProvider
    }

    func getChampionsList(page: Int, language: String) -> AnyPublisher<ChampionsListBuilder.Model, RequestError> {
        let request = ChampionsRequest(language: language, page: page)
        return serviceProvider.execute(request: request, builder: ChampionsListBuilder())
    }

}
