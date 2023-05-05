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

    private lazy var goCartAction: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    
    private lazy var headerBrandedView = HeaderBrandedView(
        leftFirstButtonAction: goBackAction,
        leftFirstButtonImageName: ImageName.backLowered,
        rightFirstButtonAction: goCartAction,
        rightFirstButtonImageName: ImageName.cart,
        frame: .zero
    )

    private let productScrollView = UIScrollView.makeScrollView()

    private let screenNameLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var addToCartAction: () -> Void = { [weak self] in
        self?.presenter.addProductToCart()
    }
    private lazy var addToCartButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, action: addToCartAction)

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
        arrangeHeaderBrandedView()
        arrangeProductScrollView()
        arrangeScreenNameLabel()
        arrangeAddToCartButton()
    }
    
    private func arrangeHeaderBrandedView() {
        view.addSubview(headerBrandedView)
        headerBrandedView.snp.makeConstraints { make in
            make.top.right.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeProductScrollView() {
        view.addSubview(productScrollView)
        productScrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBrandedView.snp.bottom)
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
