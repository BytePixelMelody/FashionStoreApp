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
    private lazy var backButton = UIButton.makeIconicButton(imageName: ImageName.backLowered, handler: goBackAction)

    private let logoImage = UIImageView(image: UIImage(named: ImageName.logo))
    
    private lazy var goCartAction: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    private lazy var goCartButton = UIButton.makeIconicButton(imageName: ImageName.cart, handler: goCartAction)
    
    private let productScrollView = UIScrollView.makeScrollView()

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
        arrangeCartButton()
        arrangeProductScrollView()
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
    
    private func arrangeCartButton() {
        view.addSubview(goCartButton)
        goCartButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeProductScrollView() {
        view.addSubview(productScrollView)
        productScrollView.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            // bottom is in footer constraints
        }
        productScrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(productScrollView.frameLayoutGuide.snp.width)
        }
        // contentLayoutGuide must have top and bottom constraints
    }
    
    private func arrangeScreenNameLabel() {
        productScrollView.addSubview(screenNameLabel)
        screenNameLabel.snp.makeConstraints { make in
            make.top.equalTo(productScrollView.contentLayoutGuide.snp.top).offset(300)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(productScrollView.contentLayoutGuide.snp.bottom).inset(30)
        }
    }

    private func arrangeAddToCartButton() {
        view.addSubview(addToCartButton)
        addToCartButton.snp.makeConstraints { make in
            make.top.equalTo(productScrollView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
}

extension ProductViewController: ProductViewProtocol {
    
}
