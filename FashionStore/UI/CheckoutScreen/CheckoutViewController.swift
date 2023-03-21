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
    private static let totalPriceLabelTitle = "$0"
    
    private let presenter: CheckoutPresenterProtocol
    
    private lazy var closeScreen: () -> Void = { [weak self] in
        self?.presenter.closeScreen()
    }
    private lazy var closeButton = UIButton.makeIconicButton(imageName: ImageName.close, handler: closeScreen)
    
    private lazy var closeCheckoutAndCart: () -> Void = { [weak self] in
        self?.presenter.closeCheckoutAndCart()
    }
    private lazy var closeCheckoutAndCartButton = UIButton.makeIconicButton(imageName: ImageName.close, handler: closeCheckoutAndCart)

    private var headerLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()

    private let spacerImage = UIImageView(image: UIImage(named: ImageName.spacer))

    private var shippingAddressLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var addAddress: () -> Void = { [weak self] in
        self?.presenter.addAddress()
    }
    private lazy var addAddressButton = UIButton.makeGrayCapsuleButton(imageName: ImageName.plus, handler: addAddress)
    
    private var paymentMethodLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()

    private lazy var addPaymentCard: () -> Void = { [weak self] in
        self?.presenter.addPaymentCard()
    }
    private lazy var addPaymentMethodButton = UIButton.makeGrayCapsuleButton(imageName: ImageName.plus, handler: addPaymentCard)

    private var checkoutIsEmptyLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
        
    private let lineImage = UIImageView(image: UIImage(named: ImageName.lineGray))

    private var totalLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()
    
    private var totalPriceLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: closeCheckoutAndCart)
    
    private lazy var placeOrder: () -> Void = { [weak self] in
        self?.presenter.placeOrder()
    }
    private lazy var placeOrderButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: placeOrder)
    
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
        headerLabel.attributedText = Self.headerTitle.uppercased().setStyle(style: .titleLargeAlignCenter)
        shippingAddressLabel.attributedText = Self.shippingAddressLabelTitle.uppercased().setStyle(style: .subHeader)
        addAddressButton.configuration?.attributedTitle = AttributedString(Self.addAddressButtonTitle.setStyle(style: .bodyLarge))
        paymentMethodLabel.attributedText = Self.paymentMethodLabelTitle.uppercased().setStyle(style: .subHeader)
        addPaymentMethodButton.configuration?.attributedTitle = AttributedString(Self.addPaymentMethodButtonTitle.setStyle(style: .bodyLarge))
        checkoutIsEmptyLabel.attributedText = Self.checkoutIsEmptyTitle.setStyle(style: .bodyLargeAlignCenter)
        continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
        placeOrderButton.configuration?.attributedTitle = AttributedString(Self.placeOrderButtonTitle.uppercased().setStyle(style: .buttonDark))
        totalLabel.attributedText = Self.totalLabelTitle.uppercased().setStyle(style: .titleSmall)
        totalPriceLabel.attributedText = Self.totalPriceLabelTitle.setStyle(style: .priceTotal)
    }
    
    private func arrangeUiElements() {
        arrangeCloseButton()
        arrangeCloseCheckoutAndCartButton()
        arrangeHeaderLabel()
        arrangeSpacerImage()
        arrangeShippingAddressLabel()
        arrangeAddAddressButton()
        arrangePaymentMethodLabel()
        arrangeAddPaymentMethodButton()
        arrangeCheckoutIsEmptyLabel()
        arrangeContinueShoppingButton()
        arrangePlaceOrderButton()
        arrangeTotalLabel()
        arrangeTotalPriceLabel()
        arrangeLineImage()
    }
    
    private func arrangeCloseButton() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeCloseCheckoutAndCartButton() {
        view.addSubview(closeCheckoutAndCartButton)
        closeCheckoutAndCartButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeHeaderLabel() {
        view.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).inset(4)
            make.height.equalTo(32)
            make.left.right.equalToSuperview().inset(50)
        }
    }

    private func arrangeSpacerImage() {
        view.addSubview(spacerImage)
        spacerImage.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(3)
            make.centerX.equalTo(headerLabel)
        }
    }
    
    private func arrangeShippingAddressLabel() {
        view.addSubview(shippingAddressLabel)
        shippingAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(spacerImage.snp.bottom).offset(30)
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
            make.top.equalTo(spacerImage.snp.bottom).offset(300)
            make.centerX.equalToSuperview()
        }
    }
    
    private func arrangeLineImage() {
        view.addSubview(lineImage)
        lineImage.snp.makeConstraints { make in
            make.bottom.equalTo(totalLabel.snp.top).offset(-15)
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    private func arrangeTotalLabel() {
        view.addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.firstBaseline.equalTo(placeOrderButton.snp.top).offset(-29)
        }
    }
    
    private func arrangeTotalPriceLabel() {
        view.addSubview(totalPriceLabel)
        totalPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.firstBaseline.equalTo(placeOrderButton.snp.top).offset(-29)
        }
    }
    
    private func arrangeContinueShoppingButton() {
        view.addSubview(continueShoppingButton)
        continueShoppingButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
    private func arrangePlaceOrderButton() {
        view.addSubview(placeOrderButton)
        placeOrderButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupUiTexts()
    }

}

extension CheckoutViewController: CheckoutViewProtocol {
    
    public func showEmptyCheckoutWithAnimation() {
        
        // show
        closeCheckoutAndCartButton.alpha = 0
        checkoutIsEmptyLabel.alpha = 0
        continueShoppingButton.alpha = 0
        
        // show
        closeCheckoutAndCartButton.isHidden = false
        checkoutIsEmptyLabel.isHidden = false
        continueShoppingButton.isHidden = false
        
        // show to actual user interaction
        view.bringSubviewToFront(closeCheckoutAndCartButton)
        view.bringSubviewToFront(checkoutIsEmptyLabel)
        view.bringSubviewToFront(continueShoppingButton)
        
        // animations
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: { [weak self] in
            // show
            self?.closeCheckoutAndCartButton.alpha = 1
            self?.checkoutIsEmptyLabel.alpha = 1
            self?.continueShoppingButton.alpha = 1
            // hide
            self?.closeButton.alpha = 0
            self?.placeOrderButton.alpha = 0
            self?.totalLabel.alpha = 0
            self?.totalPriceLabel.alpha = 0
            self?.lineImage.alpha = 0
        }) { [weak self] _ in
            // hide
            self?.closeButton.isHidden = true
            self?.placeOrderButton.isHidden = true
            self?.totalLabel.isHidden = true
            self?.totalPriceLabel.isHidden = true
            self?.lineImage.isHidden = true
        }
    }
    
    public func showFullCheckout() {
        // show
        closeButton.isHidden = false
        placeOrderButton.isHidden = false
        totalLabel.isHidden = false
        totalPriceLabel.isHidden = false
        lineImage.isHidden = false
        // hide
        closeCheckoutAndCartButton.isHidden = true
        checkoutIsEmptyLabel.isHidden = true
        continueShoppingButton.isHidden = true
    }
    
}
