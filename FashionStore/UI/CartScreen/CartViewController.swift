//
//  CartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol CartViewProtocol: AnyObject {
    func showEmptyCart()
    func showFullCart()
}

class CartViewController: UIViewController {
    
    private static let headerTitle = "Cart"
    private static let cartIsEmptyTitle = "Your card is empty.\nChoose the best goods from our catalog"
    private static let continueShoppingButtonTitle = "Continue shopping"
    private static let checkoutButtonTitle = "Checkout"
    private static let totalLabelTitle = "Total"
    private static let totalPriceLabelTitle = "$0"

    private let presenter: CartPresenterProtocol
    
    private lazy var closeScreen: () -> Void = { [weak self] in
        self?.presenter.closeScreen()
    }
    private lazy var closeButton = UIButton.makeIconicButton(imageName: ImageName.close, handler: closeScreen)

    private var headerLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()

    private let spacerImage = UIImageView(image: UIImage(named: ImageName.spacer))

    private var cartIsEmptyLabel = {
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
    
    private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: closeScreen)
    
    private lazy var checkout: () -> Void = { [weak self] in
        self?.presenter.showCheckout()
    }
    private lazy var checkoutButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: checkout)
    
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
        headerLabel.attributedText = Self.headerTitle.uppercased().setStyle(style: .titleLargeAlignCenter)
        cartIsEmptyLabel.attributedText = Self.cartIsEmptyTitle.setStyle(style: .bodyLargeAlignCenter)
        continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
        checkoutButton.configuration?.attributedTitle = AttributedString(Self.checkoutButtonTitle.uppercased().setStyle(style: .buttonDark))
        totalLabel.attributedText = Self.totalLabelTitle.uppercased().setStyle(style: .titleSmall)
        totalPriceLabel.attributedText = Self.totalPriceLabelTitle.setStyle(style: .priceTotal)
    }
    
    private func arrangeUiElements() {
        arrangeCloseButton()
        arrangeHeaderLabel()
        arrangeSpacerImage()
        arrangeCartIsEmptyLabel()
        arrangeContinueShoppingButton()
        arrangeCheckoutButton()
        arrangeTotalLabel()
        arrangeTotalPriceLabel()
        arrangeLineImage()
    }
    
    public func showEmptyCart() {
        // show
        cartIsEmptyLabel.isHidden = false
        continueShoppingButton.isHidden = false
        // hide
        checkoutButton.isHidden = true
        totalLabel.isHidden = true
        totalPriceLabel.isHidden = true
        lineImage.isHidden = true
    }
    
    public func showFullCart() {
        // show
        checkoutButton.isHidden = false
        totalLabel.isHidden = false
        totalPriceLabel.isHidden = false
        lineImage.isHidden = false
        // hide
        cartIsEmptyLabel.isHidden = true
        continueShoppingButton.isHidden = true
    }
    
    private func arrangeCloseButton() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
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
    
    private func arrangeCartIsEmptyLabel() {
        view.addSubview(cartIsEmptyLabel)
        cartIsEmptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
            make.firstBaseline.equalTo(checkoutButton.snp.top).offset(-29)
        }
    }
    
    private func arrangeTotalPriceLabel() {
        view.addSubview(totalPriceLabel)
        totalPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.firstBaseline.equalTo(checkoutButton.snp.top).offset(-29)
        }
    }
    
    private func arrangeContinueShoppingButton() {
        view.addSubview(continueShoppingButton)
        continueShoppingButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
    private func arrangeCheckoutButton() {
        view.addSubview(checkoutButton)
        checkoutButton.snp.makeConstraints { make in
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

extension CartViewController: CartViewProtocol {
    
}
