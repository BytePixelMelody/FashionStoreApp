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

    private lazy var closableHeaderView = HeaderClosableView(closeScreenHandler: closeScreenAction, headerTitle: Self.headerTitle)

    private let cartIsEmptyLabel = UILabel.makeLabel(numberOfLines: 0)
        
    private lazy var checkoutAction: () -> Void = { [weak self] in
        self?.presenter.showCheckout()
    }

    private lazy var footerTotalPriceView = FooterTotalPriceView(totalLabelTitle: Self.totalLabelTitle, currencySign: Self.currencySign, actionHandler: checkoutAction, buttonTitle: Self.checkoutButtonTitle)
    
    private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: closeScreenAction)
    
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
        
        presenter.cartIsEmptyCheck()        
    }
    
    private func setupUiTexts() {
        cartIsEmptyLabel.attributedText = Self.cartIsEmptyTitle.setStyle(style: .bodyLargeAlignCenter)
        continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeClosableHeaderView()
        arrangeCartIsEmptyLabel()
        arrangeContinueShoppingButton()
        arrangeFooterTotalPriceView()
    }
    
    private func arrangeClosableHeaderView() {
        view.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeCartIsEmptyLabel() {
        view.addSubview(cartIsEmptyLabel)
        cartIsEmptyLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
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
    
}

extension CartViewController: CartViewProtocol {
    
    // TODO: animate this func like in checkout
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
            // show
            self?.cartIsEmptyLabel.alpha = 1
            self?.continueShoppingButton.alpha = 1
            // hide
            self?.footerTotalPriceView.alpha = 0
        }) { [weak self] _ in
            // hide
            self?.footerTotalPriceView.isHidden = true
        }
    }
    
    public func showFullCart() {
        // show
        footerTotalPriceView.isHidden = false
        // hide
        cartIsEmptyLabel.isHidden = true
        continueShoppingButton.isHidden = true
    }
    
    func setTotalPrice(price: Decimal) {
        footerTotalPriceView.setTotalPrice(price: price)
    }
}
