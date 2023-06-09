//
//  CheckoutViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol CheckoutViewProtocol: AnyObject {
    func showEmptyCheckoutWithAnimation()
    func showFullCheckout()
    func showAddAddressView()
    func showFilledAddressView(firstAndLastName: String,
                               address: String,
                               cityStateZip: String,
                               country: String, 
                               phone: String)
    func showAddPaymentMethodView()
    func showFilledPaymentMethodView(paymentSystemImageName: String, paymentSystemName: String, cardLastDigits: String)
    func setTotalPrice(price: Decimal?)
    func reloadCollectionViewData()
    func updateCollectionViewItems(updatedItemIds: [CatalogItem.ID])
}

class CheckoutViewController: UIViewController {
    
    private static let headerTitle = "Checkout"
    private static let shippingAddressLabelTitle = "Shipping address"
    private static let addAddressButtonTitle = "Add shipping address"
    private static let paymentMethodLabelTitle = "Payment method"
    private static let addPaymentMethodButtonTitle = "Add payment card"
    private static let checkoutIsEmptyTitle = "Your card is empty.\nChoose the best goods from our catalog"
    private static let continueShoppingButtonTitle = "Continue shopping"
    private static let placeOrderButtonTitle = "Place order"
    private static let totalLabelTitle = "Total"
    private static let currencySign = "$"
    
    private let presenter: CheckoutPresenterProtocol
    
    private lazy var closeCheckoutAction: () -> Void = { [weak presenter] in
        presenter?.closeScreen()
    }
    private lazy var closeCheckoutAndCartAction: () -> Void = { [weak presenter] in
        presenter?.closeCheckoutAndCart()
    }
    
    private lazy var closeCheckoutHeaderView = HeaderNamedView(closeScreenAction: closeCheckoutAction, headerTitle: Self.headerTitle)
    
    private lazy var closeCheckoutAndCartHeaderView = HeaderNamedView(closeScreenAction: closeCheckoutAndCartAction, headerTitle: Self.headerTitle)
        
    private let detailsAndProductsStackView = UIStackView.makeVerticalStackView()

    private let addressContainerView = ContainerView(frame: .zero)
    private let paymentMethodContainerView = ContainerView(frame: .zero)
    
    private var filledAddressView: FilledAddressView?
    private var filledPaymentMethodView: FilledPaymentMethodView?
    
    private lazy var editAddressAction: () -> Void = { [weak presenter] in
        presenter?.editAddress()
    }

    private lazy var deleteAddressAction: () -> Void = { [weak presenter] in
        presenter?.deleteAddress()
    }

    private lazy var addAddressView = EmptyDetailsView(infoLabelText: Self.shippingAddressLabelTitle, addInfoButtonTitle: Self.addAddressButtonTitle, addInfoAction: editAddressAction)
   
    private lazy var editPaymentMethodAction: () -> Void = { [weak presenter] in
        presenter?.editPaymentMethod()
    }
    
    private lazy var deletePaymentMethodAction: () -> Void = { [weak presenter] in
        presenter?.deletePaymentCard()
    }
    
    private lazy var addPaymentMethodView = EmptyDetailsView(infoLabelText: Self.paymentMethodLabelTitle, addInfoButtonTitle: Self.addPaymentMethodButtonTitle, addInfoAction: editPaymentMethodAction)
    
    private var cartItemsCollectionView: UICollectionView?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private let checkoutIsEmptyLabel = UILabel.makeLabel(numberOfLines: 0)
        
    private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, action: closeCheckoutAndCartAction)
    
    private lazy var placeOrderAction: () -> Void = { [weak presenter] in
        presenter?.placeOrder()
    }

    private lazy var footerTotalPriceView = FooterTotalPriceView(totalLabelTitle: Self.totalLabelTitle, currencySign: Self.currencySign, buttonAction: placeOrderAction, buttonTitle: Self.placeOrderButtonTitle)

    init(presenter: CheckoutPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        Task<Void, Never> { [weak presenter] in
            do {
                // load catalog from Web
                try await presenter?.loadCatalog()
                // check cartItems for availability in the catalog, pop-up message when deleting from cart
                try await presenter?.checkCartInStock()
            } catch {
                Errors.handler.checkError(error)
            }
        }

        // create and configure collection view
        configureCollectionView()
        
        // setup texts with styles
        setupUiTexts()
        
        // fill stack with elements
        fillDetailsAndProductsStackView()
        
        // arrange layouts
        arrangeLayout()
        
        // configure collection view data source
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // turn off navigation swipe, the extension is below
        // turn navigation swipe back on is in viewWillDisappear
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        Task<Void, Never> { [weak presenter] in
            do {
                // reload cart items
                try await presenter?.reloadCart()
                presenter?.reloadCollectionView()
            } catch {
                Errors.handler.checkError(error)
            }
        }
        
        // while task is running we will fill chipping address and payment method
        presenter.fillChippingAddressAndPaymentMethod()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // turn navigation swipe back on
        if let gestureRecognizer = navigationController?.interactivePopGestureRecognizer,
           let delegate = navigationController as? any UIGestureRecognizerDelegate {
            gestureRecognizer.delegate = delegate
        }
    }
    
    private func setupUiTexts() {
        checkoutIsEmptyLabel.attributedText = Self.checkoutIsEmptyTitle.setStyle(style: .bodyLargeAlignCentered)
        continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setupUiTexts()
            cartItemsCollectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func fillDetailsAndProductsStackView() {
        detailsAndProductsStackView.addArrangedSubview(addressContainerView)
        detailsAndProductsStackView.addArrangedSubview(paymentMethodContainerView)
        detailsAndProductsStackView.setCustomSpacing(29, after: paymentMethodContainerView)
    }
    
    private func arrangeLayout() {
        arrangeCloseCheckoutHeaderView()
        arrangeCloseCheckoutAndCartHeaderView()
        arrangeDetailsAndProductsStackView()
        arrangeCartItemsCollectionView()
        arrangeContinueShoppingButton()
        arrangeFooterTotalPriceView()
        arrangeCartItemsCollectionViewBottom()
    }
    
    private func arrangeCloseCheckoutHeaderView() {
        view.addSubview(closeCheckoutHeaderView)
        closeCheckoutHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func arrangeCloseCheckoutAndCartHeaderView() {
        view.addSubview(closeCheckoutAndCartHeaderView)
        closeCheckoutAndCartHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeDetailsAndProductsStackView() {
        view.addSubview(detailsAndProductsStackView)
        detailsAndProductsStackView.snp.makeConstraints { make in
            make.top.equalTo(closeCheckoutHeaderView.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func arrangeCartItemsCollectionView() {
        guard let cartItemsCollectionView else { return }
        view.addSubview(cartItemsCollectionView)
        cartItemsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(detailsAndProductsStackView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            // bottom is in footer constraints
        }
    }
    
    private func arrangeContinueShoppingButton() {
        view.addSubview(continueShoppingButton)
        continueShoppingButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
    private func arrangeFooterTotalPriceView() {
        view.addSubview(footerTotalPriceView)
        footerTotalPriceView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func arrangeCartItemsCollectionViewBottom() {
        guard let cartItemsCollectionView else { return }
        cartItemsCollectionView.snp.makeConstraints { make in
            make.bottom.equalTo(footerTotalPriceView.snp.top).offset(-8)
        }
    }

}

extension CheckoutViewController: CheckoutViewProtocol {
    
    public func showAddAddressView() {
        addressContainerView.setSubView(addAddressView)
    }
    
    public func showFilledAddressView(firstAndLastName: String, address: String, cityStateZip: String, country: String, phone: String) {
        
        filledAddressView = FilledAddressView(
            firstLastNameLabelText: firstAndLastName,
            addressLabelText: address,
            cityStateZipLabelText: cityStateZip,
            countryLabelText: country,
            phoneLabelText: phone,
            editInfoAction: editAddressAction,
            deleteInfoAction: deleteAddressAction
        )
        
        if let filledAddressView {
            addressContainerView.setSubView(filledAddressView)
        }
    }
    
    public func showAddPaymentMethodView() {
        paymentMethodContainerView.setSubView(addPaymentMethodView)
    }
    
    public func showFilledPaymentMethodView(paymentSystemImageName: String, paymentSystemName: String, cardLastDigits: String) {
        
        filledPaymentMethodView = FilledPaymentMethodView(
            paymentSystemImageName: paymentSystemImageName,
            paymentSystemName: paymentSystemName,
            cardLastDigits: cardLastDigits,
            editInfoAction: editPaymentMethodAction,
            deleteInfoAction: deletePaymentMethodAction
        )
        
        if let filledPaymentMethodView {
            paymentMethodContainerView.setSubView(filledPaymentMethodView)
        }
    }
    
    public func showEmptyCheckoutWithAnimation() {
        
        // adding checkoutIsEmptyLabel to stackView
        detailsAndProductsStackView.addArrangedSubview(checkoutIsEmptyLabel)
        detailsAndProductsStackView.setCustomSpacing(60, after: paymentMethodContainerView)
        
        // show gradually
        closeCheckoutAndCartHeaderView.alpha = 0
        checkoutIsEmptyLabel.alpha = 0
        continueShoppingButton.alpha = 0
        
        // show
        closeCheckoutAndCartHeaderView.isHidden = false
        checkoutIsEmptyLabel.isHidden = false
        continueShoppingButton.isHidden = false
        
        // show to actual user interaction
        view.bringSubviewToFront(closeCheckoutAndCartHeaderView)
        view.bringSubviewToFront(checkoutIsEmptyLabel)
        view.bringSubviewToFront(continueShoppingButton)
        
        // animations
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
            guard let self, let cartItemsCollectionView else { return }
            // show
            closeCheckoutAndCartHeaderView.alpha = 1
            checkoutIsEmptyLabel.alpha = 1
            continueShoppingButton.alpha = 1
            // hide
            closeCheckoutHeaderView.alpha = 0
            footerTotalPriceView.alpha = 0
            // remake cartItemsCollectionView constraints
            cartItemsCollectionView.snp.remakeConstraints { [weak self] make in
                guard let self else { return }
                make.top.equalTo(detailsAndProductsStackView.snp.bottom).offset(8)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(continueShoppingButton.snp.top).offset(-8)
            }
        }) { [weak self] _ in
            guard let self else { return }
            // hide
            closeCheckoutHeaderView.isHidden = true
            footerTotalPriceView.isHidden = true
        }
    }
    
    public func showFullCheckout() {
        // deleting checkoutIsEmptyLabel from stackView
        detailsAndProductsStackView.removeArrangedSubview(checkoutIsEmptyLabel)
        detailsAndProductsStackView.setCustomSpacing(29, after: paymentMethodContainerView)

        // show
        closeCheckoutHeaderView.isHidden = false
        footerTotalPriceView.isHidden = false
        // hide
        closeCheckoutAndCartHeaderView.isHidden = true
        checkoutIsEmptyLabel.isHidden = true
        continueShoppingButton.isHidden = true
        // remake cartItemsCollectionView constraints
        guard let cartItemsCollectionView else { return }
        cartItemsCollectionView.snp.remakeConstraints { [weak self] make in
            guard let self else { return }
            make.top.equalTo(detailsAndProductsStackView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(footerTotalPriceView.snp.top).offset(-8)
        }
    }
    
    public func setTotalPrice(price: Decimal?) {
        footerTotalPriceView.setTotalPrice(price: price)
    }

}

// collection view implementing
extension CheckoutViewController {
    
    // create and configure collection view
    private func configureCollectionView() {
        // flow layout creating
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        // layout setup, automaticSize requires func preferredLayoutAttributesFitting() in cell class
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionViewFlowLayout.sectionInset = CartItemsFlowLayoutConstants.sectionInset
        collectionViewFlowLayout.minimumLineSpacing = CartItemsFlowLayoutConstants.lineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = CartItemsFlowLayoutConstants.minimumInteritemSpacing
        
        cartItemsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        // some setup of collection view
        cartItemsCollectionView?.alwaysBounceVertical = true // springing (bounce)
        cartItemsCollectionView?.showsVerticalScrollIndicator = false // no scroll indicator
    }
    
    enum Section: Hashable {
        case cartItemSection
    }
    
    enum Item: Hashable {
        case cartItem(CatalogItem.ID)
    }
    
    private func createCartItemCellRegistration() -> UICollectionView.CellRegistration<CartItemCellView, CatalogItem.ID> {
        return UICollectionView.CellRegistration<CartItemCellView, CatalogItem.ID> { [weak self] cell, indexPath, itemId in
            
            guard let self else { return }
            
            let loadImageAction: (String) async throws -> UIImage? = { [weak presenter] imageName in
                // load image by presenter
                return try await presenter?.loadImage(imageName: imageName)
            }
            
            let minusButtonAction: (UUID, Int) async throws -> Void = { [weak presenter] itemId, newCount in
                try await presenter?.reduceCartItemCount(itemId: itemId, newCount: newCount)
            }
            
            let plusButtonAction: (UUID, Int) async throws -> Void = { [weak presenter] itemId, newCount in
                try await presenter?.increaseCartItemCount(itemId: itemId, newCount: newCount)
            }
            
            // find info in catalog
            guard let product = presenter.findProduct(itemId: itemId) else { return }
            guard let color = presenter.findColor(itemId: itemId) else { return }
            guard let catalogItem = presenter.findCatalogItem(itemId: itemId) else { return }
            guard let cartItem = presenter.findCartItem(itemId: itemId) else { return }

            let productName = product.name
            let colorName = color.name
            let size = catalogItem.size
            
            cell.setup(
                imageName: color.images.first,
                loadImageAction: loadImageAction,
                itemBrand: product.brand,
                itemNameColorSize: "\(productName), \(colorName), \(size)",
                itemId: itemId,
                minusButtonAction: minusButtonAction,
                count: cartItem.count,
                plusButtonAction: plusButtonAction,
                itemPrice: product.price
            )
        }
    }
    
    private func configureDataSource() {
        let cartItemCellRegistration = createCartItemCellRegistration()
        
        guard let cartItemsCollectionView else { return }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: cartItemsCollectionView) {collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .cartItem(let itemId):
                return collectionView.dequeueConfiguredReusableCell(using: cartItemCellRegistration, for: indexPath, item: itemId)
            }
        }
    }
    
    func reloadCollectionViewData() {
        guard let dataSource, let cartItems = presenter.getCartItems() else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        // adding sections to snapshot
        snapshot.appendSections([.cartItemSection])
        // adding products to snapshot by Item enum entities .product(Product)
        snapshot.appendItems(cartItems.map { Item.cartItem($0.itemId) })
        // apply dataSource with correct animations
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // if count changes
    func updateCollectionViewItems(updatedItemIds: [CatalogItem.ID]) {
        guard let dataSource else { return }
        
        var snapshot = dataSource.snapshot()
        let updatedCartItems = updatedItemIds.compactMap { presenter.findCartItem(itemId: $0) }
        let updatedItems = updatedCartItems.map { Item.cartItem($0.itemId) }
        snapshot.reconfigureItems(updatedItems)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// turn off navigation swipes
extension CheckoutViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
