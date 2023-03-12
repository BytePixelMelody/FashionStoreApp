//
//  CartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol CartViewProtocol: AnyObject {
    
}

class CartViewController: UIViewController {
    private static let headerTitle = "Cart"
    private static let cartIsEmptyTitle = "Your card is empty.\nChoose the best goods from our catalog"
    private static let continueShoppingButtonTitle = "Continue shopping"
    private static let checkoutButtonTitle = "Checkout"

    private let presenter: CartPresenterProtocol
    
    private lazy var closeCart: () -> Void = { [weak self] in
        self?.presenter.closeScreen()
    }
    private lazy var closeButton = UIButton.makeIconicButton(imageName: ImageName.close, handler: closeCart)

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
    
    private lazy var continueShoppingButton = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: closeCart)
    
    private lazy var checkout: () -> Void = { [weak self] in
        self?.presenter.checkout()
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
    
    private func setupUiTexts() {
        headerLabel.attributedText = Self.headerTitle.uppercased().setStyle(style: .titleLargeAlignCenter)
        
        if presenter.cartIsEmpty() {
            cartIsEmptyLabel.attributedText = Self.cartIsEmptyTitle.setStyle(style: .bodyLargeAlignCenter)
            continueShoppingButton.configuration?.attributedTitle = AttributedString(Self.continueShoppingButtonTitle.uppercased().setStyle(style: .buttonDark))
        } else {
            checkoutButton.configuration?.attributedTitle = AttributedString(Self.checkoutButtonTitle.uppercased().setStyle(style: .buttonDark))
        }
    }
    
    private func arrangeUiElements() {
        arrangeCloseButton()
        arrangeHeaderLabel()
        arrangeSpacerImage()
        
        if presenter.cartIsEmpty() {
            arrangeCartIsEmptyLabel()
            arrangeContinueShoppingButton()
        } else {
            arrangeCheckoutButton()
        }
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
            make.top.equalTo(closeButton.snp.bottom).offset(6)
            make.height.equalTo(32)
            make.centerX.width.equalTo(view.readableContentGuide)
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
        debugPrint("Accessibility settings was changed - scale font size on ProductViewController")
    }
}

extension CartViewController: CartViewProtocol {
    
}
