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
}

enum ChampionsListSection: String, CaseIterable {
    case champion
}

class ChampionsListViewModel {

    @Published var state: ChampionsViewOutEvent = .loading
    let eventSubject = PassthroughSubject<ChampionsViewInEvent, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    private var page = 1
    private let service: ChampionsService
    
    init(service: ChampionsService = ChampionsService()) {
        self.service = service
        
        eventSubject
            .sink { [weak self] in
                self?.handleEvent($0)
            }
            .store(in: &cancellables)
    }
    
    func handleEvent(_ event: ChampionsViewInEvent) {
        switch event {
        case .reload, .load, .pullToRefresh:
            load()
        }
    }
    
    func load() {
        page = 1
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
                    self?.state = .success(model)
                })
            .store(in: &cancellables)
    }
    
}
