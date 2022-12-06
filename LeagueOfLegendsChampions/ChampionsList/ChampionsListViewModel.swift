import Combine
import Foundation

enum ChampionsViewOutEvent {
    case loading
    case failureLoading(RequestError)
    case success(ChampionsListBuilder.Model)
}

enum ChampionsViewInEvent {
    case load
    case reload
    case pullToRefresh
    case prefetchNextPage(index: Int)
}

enum ChampionsListSection: String, CaseIterable {
    case champion
}

class ChampionsListViewModel {

    @Published var state: ChampionsViewOutEvent = .loading
    let eventSubject = PassthroughSubject<ChampionsViewInEvent, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var page = 1
    private var model: ChampionsListBuilder.Model?
    private let service: ChampionsService
    
    init(service: ChampionsService = ChampionsService()) {
        self.service = service
        
        eventSubject
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &cancellables)
    }
    
    func handleEvent(_ event: ChampionsViewInEvent) {
        switch event {
        case .reload, .load, .pullToRefresh:
            page = 1
            model = nil
            load()
        case .prefetchNextPage(let index):
            let hasNextPage = self.model?.hasNextPage ?? false
            let currentChampion = self.model?.champions[index]
            let lastChampion = self.model?.champions.last
            if (hasNextPage && currentChampion == lastChampion) {
                page += 1
                load()
            }
        }
    }
    
    func load() {
        service.getChampionsList(page: page)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.state = .failureLoading(error)
                    }
                },
                receiveValue: { [weak self] model in
                    guard let `self` = self else { return }
                    self.state = .success(self.handleModel(model))
                })
            .store(in: &cancellables)
    }
    
    func handleModel(_ model: ChampionsListBuilder.Model) -> ChampionsListBuilder.Model {
        let newModel = self.model?.updateModel(model) ?? model
        self.model = newModel
        return newModel
    }

}
