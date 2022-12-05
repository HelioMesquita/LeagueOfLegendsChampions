import Combine
import UIKit

class ListViewController: UIViewController {
    
    typealias Champion = ListBuilder.Model.ChampionModel
    typealias Section = ListViewModel.Section
    
    lazy var refreshControl = UIRefreshControlPublisher()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(cellType: ChampionCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(76))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(76))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            let section = NSCollectionLayoutSection(group: group)

            return section
        }
    }
    
    lazy var dataSource: UICollectionViewDiffableDataSource<Section, Champion> = {
        var dataSource = UICollectionViewDiffableDataSource<Section, Champion>(collectionView: self.collectionView) { (collectionView, indexPath, element) -> UICollectionViewCell? in
            let cell: ChampionCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.setCell(element)
            return cell
        }
        return dataSource
    }()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: ListViewModel

    init(viewModel: ListViewModel = ListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addCollectionView()
        
        refreshControl.pullToRefreshPublisher
            .map { _ in ListViewInEvent.reload }
            .subscribe(viewModel.eventSubject)
            .store(in: &cancellables)
                
        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.collectionView.refreshControl?.beginRefreshing()
                    self?.viewModel.eventSubject.send(.load)
                    
                case .failureLoading(let error):
                    self?.collectionView.refreshControl?.endRefreshing()
                    let tryAgain = UIAlertAction(title: R.string.localizable.tryAgain(), style: .default) { [weak self] _ in
                        self?.viewModel.eventSubject.send(.reload)
                    }
                    let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel)
                    let presentViewController = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
                    presentViewController.addAction(tryAgain)
                    presentViewController.addAction(cancel)
                    self?.present(presentViewController, animated: true)
                    
                case .success(let model):
                    self?.collectionView.refreshControl?.endRefreshing()
                    var snapshot = NSDiffableDataSourceSnapshot<Section, Champion>()
                    snapshot.appendSections([.champion])
                    snapshot.appendItems(model.champions, toSection: .champion)
                    self?.dataSource.apply(snapshot, animatingDifferences: false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func addCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

