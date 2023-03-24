//
//  ProductViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol ProductViewProtocol: AnyObject {
    
}

class ProductViewController: UIViewController {
    private static let screenNameTitle = "Product\nDescription"
    private static let addToCartButtonTitle = "Add to cart"
    
    private let presenter: ProductPresenterProtocol

    private lazy var goBackAction: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }
    private lazy var backButton = UIButton.makeIconicButton(imageName: ImageName.back, handler: goBackAction)

    private let logoImage = UIImageView(image: UIImage(named: ImageName.logo))
    
    private lazy var goCartAction: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    private lazy var goCartButton = UIButton.makeIconicButton(imageName: ImageName.cart, handler: goCartAction)
    
    private let screenNameLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var addToCartAction: () -> Void = { [weak self] in
        self?.presenter.addProductToCart()
    }
    private lazy var addToCartButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, handler: addToCartAction)

    init(presenter: ProductPresenterProtocol) {
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
        screenNameLabel.attributedText = Self.screenNameTitle.uppercased().setStyle(style: .titleLargeAlignLeft)
        addToCartButton.configuration?.attributedTitle = AttributedString(Self.addToCartButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeGoBackButton()
        arrangeLogoImage()
        arrangeGoCartButton()
        arrangeScreenNameLabel()
        arrangeAddToCartButton()
    }
    
    private func arrangeGoBackButton() {
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeLogoImage() {
        view.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeGoCartButton() {
        view.addSubview(goCartButton)
        goCartButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeScreenNameLabel() {
        view.addSubview(screenNameLabel)
        screenNameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func arrangeAddToCartButton() {
        view.addSubview(addToCartButton)
        addToCartButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
}

extension ProductViewController: ProductViewProtocol {
    
}
