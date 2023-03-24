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
    func setTotalPrice(price: Decimal)
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
    
    private lazy var closeCheckoutAction: () -> Void = { [weak self] in
        self?.presenter.closeScreen()
    }
    private lazy var closeCheckoutAndCartAction: () -> Void = { [weak self] in
        self?.presenter.closeCheckoutAndCart()
    }
    
    private lazy var closeCheckoutHeaderView = HeaderClosableView(closeScreenHandler: closeCheckoutAction, headerTitle: Self.headerTitle)
    
    private lazy var closeCheckoutAndCartHeaderView = HeaderClosableView(closeScreenHandler: closeCheckoutAndCartAction, headerTitle: Self.headerTitle)

    private let shippingAddressLabel = UILabel.makeLabel(numberOfLines: 1)
    
    private lazy var addAddressAction: () -> Void = { [weak self] in
        self?.presenter.addAddress()
    }
    private lazy var addAddressButton = UIButton.makeGrayCapsuleButton(imageName: ImageName.plus, handler: addAddressAction)
    
    private let paymentMethodLabel = UILabel.makeLabel(numberOfLines: 1)

    private lazy var addPaymentCardAction: () -> Void = { [weak self] in
        self?.presenter.addPaymentCard()
    }
    private lazy var addPaymentMethodButton = UIButton.makeGrayCapsuleButton(imageName: ImageName.plus, handler: addPaymentCardAction)

    private let checkoutIsEmptyLabel = UILabel.makeLabel(numberOfLines: 0)
        
   private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: closeCheckoutAndCartAction)
    
    private lazy var placeOrderAction: () -> Void = { [weak self] in
        self?.presenter.placeOrder()
    }

    private lazy var footerTotalPriceView = FooterTotalPriceView(totalLabelTitle: Self.totalLabelTitle, currencySign: Self.currencySign, actionHandler: placeOrderAction, buttonTitle: Self.placeOrderButtonTitle)

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

        setupUiTexts()
        arrangeUiElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.checkoutIsEmptyCheck()
    }
    
    private func setupUiTexts() {
        shippingAddressLabel.attributedText = Self.shippingAddressLabelTitle.uppercased().setStyle(style: .subHeader)
        addAddressButton.configuration?.attributedTitle = AttributedString(Self.addAddressButtonTitle.setStyle(style: .bodyLarge))
        paymentMethodLabel.attributedText = Self.paymentMethodLabelTitle.uppercased().setStyle(style: .subHeader)
        addPaymentMethodButton.configuration?.attributedTitle = AttributedString(Self.addPaymentMethodButtonTitle.setStyle(style: .bodyLarge))
        checkoutIsEmptyLabel.attributedText = Self.checkoutIsEmptyTitle.setStyle(style: .bodyLargeAlignCenter)
        continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeCloseCheckoutHeaderView()
        arrangeCloseCheckoutAndCartHeaderView()
        arrangeShippingAddressLabel()
        arrangeAddAddressButton()
        arrangePaymentMethodLabel()
        arrangeAddPaymentMethodButton()
        arrangeCheckoutIsEmptyLabel()
        arrangeContinueShoppingButton()
        arrangeFooterTotalPriceView()
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
    
    private func arrangeShippingAddressLabel() {
        view.addSubview(shippingAddressLabel)
        shippingAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(closeCheckoutHeaderView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func arrangeAddAddressButton() {
        view.addSubview(addAddressButton)
        addAddressButton.snp.makeConstraints { make in
            make.top.equalTo(shippingAddressLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func arrangePaymentMethodLabel() {
        view.addSubview(paymentMethodLabel)
        paymentMethodLabel.snp.makeConstraints { make in
            make.top.equalTo(addAddressButton.snp.bottom).offset(36)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func arrangeAddPaymentMethodButton() {
        view.addSubview(addPaymentMethodButton)
        addPaymentMethodButton.snp.makeConstraints { make in
            make.top.equalTo(paymentMethodLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    private func arrangeCheckoutIsEmptyLabel() {
        view.addSubview(checkoutIsEmptyLabel)
        checkoutIsEmptyLabel.snp.makeConstraints { make in
            make.top.equalTo(closeCheckoutHeaderView.snp.bottom).offset(300)
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

extension CheckoutViewController: CheckoutViewProtocol {
    
    public func showEmptyCheckoutWithAnimation() {
        
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
            // show
            self?.closeCheckoutAndCartHeaderView.alpha = 1
            self?.checkoutIsEmptyLabel.alpha = 1
            self?.continueShoppingButton.alpha = 1
            // hide
            self?.closeCheckoutHeaderView.alpha = 0
            self?.footerTotalPriceView.alpha = 0
        }) { [weak self] _ in
            // hide
            self?.closeCheckoutHeaderView.isHidden = true
            self?.footerTotalPriceView.isHidden = true
        }
    }
    
    public func showFullCheckout() {
        // show
        closeCheckoutHeaderView.isHidden = false
        footerTotalPriceView.isHidden = false
        // hide
        closeCheckoutAndCartHeaderView.isHidden = true
        checkoutIsEmptyLabel.isHidden = true
        continueShoppingButton.isHidden = true
    }
    
    func setTotalPrice(price: Decimal) {
        footerTotalPriceView.setTotalPrice(price: price)
    }
    
}
