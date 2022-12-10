import Combine
import Foundation

enum ChampionsViewOutEvent: Equatable {

    case loading
    case failure(RequestError)
    case success(ChampionsListBuilder.Model)

    static func == (lhs: ChampionsViewOutEvent, rhs: ChampionsViewOutEvent) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.failure, .failure):
            return true
        case (.success, .success):
            return true
        default:
            return false
        }
    }
}

enum ChampionsViewInEvent {
    case load
    case prefetchNextPage(index: Int)
}

enum ChampionsListSection: String, CaseIterable {
    case champion
}

class ChampionsListViewModel {

    @Published private(set) var state: ChampionsViewOutEvent = .loading
    let eventSubject = PassthroughSubject<ChampionsViewInEvent, Never>()

    private var cancellables = Set<AnyCancellable>()
    private var page = 1
    fileprivate var model: ChampionsListBuilder.Model?
    private let service: ChampionsServiceProtocol

    init(service: ChampionsServiceProtocol = ChampionsService()) {
        self.service = service

        eventSubject
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &cancellables)
    }

    private func handleEvent(_ event: ChampionsViewInEvent) {
        switch event {
        case .load:
            page = 1
            model = nil
            load()
        case .prefetchNextPage(let index):
            guard let model = model else { return }
            let hasNextPage = model.hasNextPage
            let currentChampion = model.champions[index]
            let lastChampion = model.champions.last
            if hasNextPage && currentChampion == lastChampion {
                page += 1
                load()
            }
        }
    }

    private func load() {
        service.getChampionsList(page: page, language: Locale.preferredLanguages[0] as String)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.state = .failure(error)
                    }
                },
                receiveValue: { [weak self] model in
                    guard let `self` = self else { return }
                    self.state = .success(self.handleModel(model))
                })
            .store(in: &cancellables)
    }

    private func handleModel(_ model: ChampionsListBuilder.Model) -> ChampionsListBuilder.Model {
        let newModel = self.model?.updateModel(model) ?? model
        self.model = newModel
        return newModel
    }

}
