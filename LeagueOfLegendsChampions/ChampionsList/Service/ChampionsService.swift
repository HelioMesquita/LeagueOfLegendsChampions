import Combine
import UIKit

class ChampionsService {
    
    private let serviceProvider: ServiceProviderProtocol

    init(serviceProvider: ServiceProviderProtocol = ServiceProvider()) {
        self.serviceProvider = serviceProvider
    }

    func getChampionsList(page: Int = 1, language: String = Locale.preferredLanguages[0] as String) -> AnyPublisher<ChampionsListBuilder.Model, RequestError> {
        let request = ChampionsRequest(language: language, page: page)
        return serviceProvider.execute(request: request, builder: ChampionsListBuilder())
    }
    
}
