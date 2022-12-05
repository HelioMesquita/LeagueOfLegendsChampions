import Combine
import Foundation

enum ListViewOutEvent {
    case loading
    case failureLoading(RequestError)
    case success(ListBuilder.Model)
}

enum ListViewInEvent {
    case load
    case reload
    case pullToRefresh
    case viewDidAppear
}

class ListViewModel {
    let eventSubject = PassthroughSubject<ListViewInEvent, Never>()
    
    enum Section: String, CaseIterable {
        case champion
    }
    
    @Published
    var state: ListViewOutEvent = .loading

    var cancellables = Set<AnyCancellable>()
    private let service: ListService
    private var page = 1
    
    init(service: ListService = ListService()) {
        self.service = service
        
        eventSubject
            .sink { [weak self] in
                self?.handleEvent($0)
            }
            .store(in: &cancellables)
    }
    
    func handleEvent(_ event: ListViewInEvent) {
        switch event {
        case .reload, .load:
            load()
        case .pullToRefresh:
            break
        case .viewDidAppear:
            break
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
                    self?.state = .success(model)
                })
            .store(in: &cancellables)
    }
    
}
