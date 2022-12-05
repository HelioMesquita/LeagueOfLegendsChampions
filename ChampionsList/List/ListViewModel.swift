import Combine
import Foundation

class AppState {
    
}

class Loading: AppState {
    
}

class FailureLoading: AppState {
    
}

class Loaded: AppState {
    let model: ListBuilder.Model
    
    init(model: ListBuilder.Model) {
        self.model = model
    }
}

protocol BaseViewModel {
    var eventSubject: CurrentValueSubject<AppState, Never> { get set }
    var cancellables: Set<AnyCancellable>  { get set }
}

class ListViewModel: BaseViewModel {
    
    enum Section: String, CaseIterable {
        case champion
    }
    
    var eventSubject = CurrentValueSubject<AppState, Never>(Loading())
    var cancellables = Set<AnyCancellable>()
    private let service: ListService
    private var page = 1
    
    init(service: ListService = ListService()) {
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
                receiveValue: { [weak self] model in
                    self?.eventSubject.send(Loaded(model: model))
                })
            .store(in: &cancellables)
    }
    
}
