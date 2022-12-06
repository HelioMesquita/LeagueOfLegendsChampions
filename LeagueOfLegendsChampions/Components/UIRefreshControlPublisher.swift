import Combine
import UIKit

class UIRefreshControlPublisher: UIRefreshControl {
    
    private lazy var valueChangedSubject = PassthroughSubject<Void, Never>()
    
    var pullToRefreshPublisher: AnyPublisher<Void, Never> {
        valueChangedSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(handleValue), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleValue() {
        valueChangedSubject.send()
    }

}
