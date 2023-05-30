//
//  CartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol CartViewProtocol: AnyObject {
    func showEmptyCartWithAnimation()
    func showFullCart()
    func setTotalPrice(price: Decimal)
}

class CartViewController: UIViewController {
    
    private static let headerTitle = "Cart"
    private static let cartIsEmptyTitle = "Your card is empty.\nChoose the best goods from our catalog"
    private static let continueShoppingButtonTitle = "Continue shopping"
    private static let checkoutButtonTitle = "Checkout"
    private static let totalLabelTitle = "Total"
    private static let currencySign = "$"

    private let presenter: CartPresenterProtocol
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.closeScreen()
    }

    private lazy var closableHeaderView = HeaderNamedView(closeScreenAction: closeScreenAction, headerTitle: Self.headerTitle)

    private let productsScrollView = UIScrollView.makeScrollView()

    private let cartIsEmptyLabel = UILabel.makeLabel(numberOfLines: 0)
        
    private lazy var checkoutAction: () -> Void = { [weak self] in
        self?.presenter.showCheckout()
    }

    private lazy var footerTotalPriceView = FooterTotalPriceView(totalLabelTitle: Self.totalLabelTitle, currencySign: Self.currencySign, buttonAction: checkoutAction, buttonTitle: Self.checkoutButtonTitle)
    
    private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, action: closeScreenAction)
    
    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUiTexts()
        arrangeUiElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // turn off navigation swipe, the extension is below
        // turn navigation swipe back on is in viewWillDisappear
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        Task<Void, Never> { [weak self] in
            do {
                // load catalog from Web
                try await self?.presenter.loadCatalog()
                // check cartItems for availability in the catalog, pop-up message when deleting from cart
                try await self?.presenter.checkCartInStock()
                // load synchronised cart
                try await self?.presenter.loadCart()
                
                // TODO: delete this
                self?.presenter.showMockView()
            } catch {
                Errors.handler.checkError(error)
            }
        }
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
        cartIsEmptyLabel.attributedText = Self.cartIsEmptyTitle.setStyle(style: .bodyLargeAlignCentered)
        continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeClosableHeaderView()
        arrangeProductsScrollView()
        arrangeCartIsEmptyLabel()
        arrangeContinueShoppingButton()
        arrangeFooterTotalPriceView()
        arrangeProductsScrollViewBottom()
    }
    
    private func arrangeClosableHeaderView() {
        view.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeProductsScrollView() {
        view.addSubview(productsScrollView)
        productsScrollView.snp.makeConstraints { make in
            make.top.equalTo(closableHeaderView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            // bottom is in footer constraints
        }
        productsScrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(productsScrollView.frameLayoutGuide.snp.width)
        }
        // contentLayoutGuide must have top and bottom constraints
    }
    
    // TODO: after adding Collection View - remake productsScrollView.contentLayoutGuide to it, add put label on view with constraint header.offset(100)
    private func arrangeCartIsEmptyLabel() {
        productsScrollView.addSubview(cartIsEmptyLabel)
        cartIsEmptyLabel.snp.makeConstraints { make in
            make.top.equalTo(productsScrollView.contentLayoutGuide.snp.top).offset(100)
            make.left.right.equalTo(productsScrollView.contentLayoutGuide).inset(16)
            make.bottom.equalTo(productsScrollView.contentLayoutGuide.snp.bottom)
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
    
    private func arrangeProductsScrollViewBottom() {
        productsScrollView.snp.makeConstraints { make in
            make.bottom.equalTo(footerTotalPriceView.snp.top).offset(-8)
        }
    }

}

extension CartViewController: CartViewProtocol {
    
    public func showEmptyCartWithAnimation() {
        
        // show gradually
        cartIsEmptyLabel.alpha = 0
        continueShoppingButton.alpha = 0
        
        // show
        cartIsEmptyLabel.isHidden = false
        continueShoppingButton.isHidden = false
        
        // show to actual user interaction
        view.bringSubviewToFront(cartIsEmptyLabel)
        view.bringSubviewToFront(continueShoppingButton)
        
        // hide
        footerTotalPriceView.isHidden = true
        
        // animations
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
            guard let self else { return }
            // show
            cartIsEmptyLabel.alpha = 1
            continueShoppingButton.alpha = 1
            // hide
            footerTotalPriceView.alpha = 0
            // remake scrollView constraints
            productsScrollView.snp.remakeConstraints { [weak self] make in
                guard let self else { return }
                make.top.equalTo(closableHeaderView.snp.bottom).offset(5)
                make.left.right.equalToSuperview()
                make.width.equalTo(productsScrollView.contentLayoutGuide.snp.width)
                make.bottom.equalTo(continueShoppingButton.snp.top).offset(-8)
            }

        }) { [weak self] _ in
            guard let self else { return }
            // hide
            footerTotalPriceView.isHidden = true
        }
    }
    
    public func showFullCart() {
        // show
        footerTotalPriceView.isHidden = false
        // hide
        cartIsEmptyLabel.isHidden = true
        continueShoppingButton.isHidden = true
        // remake scrollView constraints
        productsScrollView.snp.remakeConstraints { [weak self] make in
            guard let self else { return }
            make.top.equalTo(closableHeaderView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.width.equalTo(productsScrollView.contentLayoutGuide.snp.width)
            make.bottom.equalTo(footerTotalPriceView.snp.top).offset(-8)
        }
    }
    
    func setTotalPrice(price: Decimal) {
        footerTotalPriceView.setTotalPrice(price: price)
    }
    
    // TODO: delete this
    func addMockCellView() {
//        let mockCellView = CartItemCellView(
//            imageName: <#T##String?#>,
//            loadImageAction: <#T##(String) async throws -> UIImage#>,
//            itemBrand: <#T##String#>,
//            itemNameColorSize: <#T##String#>,
//            itemId: <#T##UUID#>,
//            minusButtonAction: <#T##(UUID) async throws -> Int#>,
//            count: <#T##Int#>,
//            plusButtonAction: <#T##(UUID) async throws -> Int#>,
//            itemPrice: <#T##Decimal#>
//        )
    }
}

// turn off navigation swipes
extension CartViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
