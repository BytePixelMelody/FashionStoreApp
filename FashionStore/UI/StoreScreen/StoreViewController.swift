//
//  StartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

// Interesting implementations:
// 1. Font styles with dynamic scaling
// 2. Keychain service with iCloud support
// 3. Router with custom routing and custom animations

// Interesting but not implemented:
// 1. Custom UINavigationBar - using undocumented methods

// Backlog:

// Technical solutions for speed and stability that may be done in future:
// - Collection View with different cell types in checkout
// - Cart swipe to delete
// - Unit tests
// - Database write to SwiftData after loading from backend

// Functionality that may be done in future:
// 1. Many bank cards support
// 2. Item colors and sizes support
// 3. Favorites
// 4. Search
// 5. Menu
// 6. Login

import UIKit
import SnapKit

protocol StoreViewProtocol: AnyObject {

}

final class StoreViewController: UIViewController {

    private let presenter: StorePresenterProtocol

    private lazy var goCartAction: () -> Void = { [weak presenter] in
        presenter?.showCart()
    }

    private lazy var headerBrandedView = HeaderBrandedView(
        rightFirstButtonAction: goCartAction,
        rightFirstButtonImageName: ImageName.cart,
        frame: .zero
    )

    private var productsCollectionView: UICollectionView?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private let refreshControl = UIRefreshControl(frame: .zero)

    init(presenter: StorePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        // create and configure collection view
        configureCollectionView()

        // arrange layouts
        arrangeLayout()

        // configure collection view data source
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task<Void, Never> { [weak self] in
            guard let self else { return }
            do {
                try await presenter.loadCatalog()
                // apply data snapshot to collection view
                reloadCollectionViewData()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            productsCollectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    private func arrangeLayout() {
        arrangeHeaderBrandedView()
        arrangeProductsCollectionView()
    }

    private func arrangeHeaderBrandedView() {
        view.addSubview(headerBrandedView)
        headerBrandedView.snp.makeConstraints { make in
            make.top.right.left.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func arrangeProductsCollectionView() {
        guard let productsCollectionView else { return }
        view.addSubview(productsCollectionView)
        productsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerBrandedView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

}

// collection view implementing
extension StoreViewController {

    // create and configure collection view
    private func configureCollectionView() {
        // flow layout creating
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        // layout setup, automaticSize requires func preferredLayoutAttributesFitting() in cell class
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewFlowLayout.sectionInset = ProductsFlowLayoutConstants.sectionInset
        collectionViewFlowLayout.minimumLineSpacing = ProductsFlowLayoutConstants.lineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = ProductsFlowLayoutConstants.minimumInteritemSpacing

        productsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        // some setup of collection view
        productsCollectionView?.alwaysBounceVertical = true // springing (bounce)
        productsCollectionView?.showsVerticalScrollIndicator = false // no scroll indicator

        // adding the refresh control
        refreshControl.addAction(UIAction { _ in
            Task<Void, Never> { [weak self] in
                guard let self else { return }
                do {
                    try await presenter.loadCatalog()
                    // apply data snapshot to collection view
                    reloadCollectionViewData()
                } catch {
                    Errors.handler.checkError(error)
                }
                refreshControl.endRefreshing()
            }
        }, for: .primaryActionTriggered)
        productsCollectionView?.refreshControl = refreshControl
    }

    enum Section: Hashable {
        case productSection
    }

    enum Item: Hashable {
        case product(Product)
    }

    private func createProductCellRegistration() -> UICollectionView.CellRegistration<ProductCellView, Product> {
        return UICollectionView.CellRegistration<ProductCellView, Product> { [weak presenter] cell, _, product in

            let cellTapAction: (UUID, UIImage?) -> Void = { [weak presenter] productID, image in
                presenter?.showProduct(productID: productID, image: image)
            }

            let loadImageAction: (String) async throws -> UIImage? = { [weak presenter] imageName in
                // load image by presenter
                return try await presenter?.loadImage(imageName: imageName)
            }

            cell.setup(
                productBrandLabelTitle: product.brand,
                productNameLabelTitle: product.name,
                productPriceLabelTitle: "$" + product.price.formatted(.number.precision(.fractionLength(0...2))),
                productID: product.id,
                cellTapAction: cellTapAction,
                imageName: product.images.first,
                loadImageAction: loadImageAction
            )
        }
    }

    private func configureDataSource() {
        let productCellRegistration = createProductCellRegistration()

        guard let productsCollectionView else { return }
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: productsCollectionView
        ) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .product(let product):
                return collectionView.dequeueConfiguredReusableCell(using: productCellRegistration, for: indexPath, item: product)
            }
        }
    }

    private func reloadCollectionViewData() {
        guard let products = presenter.getProducts() else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        // adding sections to snapshot
        snapshot.appendSections([.productSection])
        // adding products to snapshot by Item enum entities .product(Product)
        snapshot.appendItems(products.map { Item.product($0) })
        // reload changes
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

}

extension StoreViewController: StoreViewProtocol {

}
