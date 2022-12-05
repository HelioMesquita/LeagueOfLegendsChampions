import Combine
import UIKit

class ListInteractor {
    
    let serviceProvider: ServiceProviderProtocol

    init(serviceProvider: ServiceProviderProtocol = ServiceProvider()) {
        self.serviceProvider = serviceProvider
    }

    func getChampionsList(page: Int = 1, language: String = Locale.preferredLanguages[0] as String) -> AnyPublisher<ListResponse, RequestError> {
        let provider = ListProvider(language: language, page: page)
        return serviceProvider.execute(request: provider)
    }
    
}
