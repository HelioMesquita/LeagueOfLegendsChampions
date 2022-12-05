import Combine
import Foundation

class AppState {
    
}

class Loading: AppState {
    
}

class FailureLoading: AppState {
    
}

class Loaded: AppState {
    let response: ListResponse
    
    init(response: ListResponse) {
        self.response = response
    }
}

protocol BaseViewModel {
    var eventSubject: CurrentValueSubject<AppState, Never> { get set }
    var cancellables: Set<AnyCancellable>  { get set }
}

class ListViewModel: BaseViewModel {
    
    var eventSubject = CurrentValueSubject<AppState, Never>(Loading())
    var cancellables = Set<AnyCancellable>()
    private let service: ListInteractor
    private var page = 1
    
    init(service: ListInteractor = ListInteractor()) {
        self.service = service
                
        service.getChampionsList(page: page)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        self?.eventSubject.send(FailureLoading())
                    }
                },
                receiveValue: { [weak self] listResponse in
                    self?.eventSubject.send(Loaded(response: listResponse))
                })
            .store(in: &cancellables)
    }
    
}
