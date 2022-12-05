import Combine
import UIKit

class ListViewController: UIViewController {
    
    typealias Champion = ListBuilder.Model.ChampionModel
    typealias Section = ListViewModel.Section
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(cellType: ChampionCell.self)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.refreshControl = UIRefreshControl()
        return collectionView
    }()
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
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
            cell.titleLabel.text = element.name
            cell.setImage(image: element.image)
            return cell
        }
        return dataSource
    }()
    
    
    private var cancellables = Set<AnyCancellable>()
//    private let rootView = ListView()
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
        
        viewModel.eventSubject
            .sink { [weak self] state in
                print(state)
                if let state = state as? Loaded {
                    var snapshot = NSDiffableDataSourceSnapshot<Section, Champion>()
                    snapshot.appendSections([.champion])
                    snapshot.appendItems(state.model.champions, toSection: .champion)
                    self?.dataSource.apply(snapshot, animatingDifferences: false)
                }
            }
            .store(in: &cancellables)
    }
    
    private func addCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

