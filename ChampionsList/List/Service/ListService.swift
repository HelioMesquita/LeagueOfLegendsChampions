import Combine
import UIKit

class ListService {
    
    let serviceProvider: ServiceProviderProtocol

    init(serviceProvider: ServiceProviderProtocol = ServiceProvider()) {
        self.serviceProvider = serviceProvider
    }

    func getChampionsList(page: Int = 1, language: String = Locale.preferredLanguages[0] as String) -> AnyPublisher<ListBuilder.Model, RequestError> {
        let request = ListRequest(language: language, page: page)
        return serviceProvider.execute(request: request, builder: ListBuilder())
    }
    
}
