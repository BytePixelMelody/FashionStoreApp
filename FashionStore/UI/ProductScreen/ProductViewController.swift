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

    private lazy var goBack: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }
    private lazy var backButton = UIButton.makeIconicButton(imageName: ImageName.back, handler: goBack)

    private let logoImage = UIImageView(image: UIImage(named: ImageName.logo))
    
    private lazy var goCart: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    private lazy var goCartButton = UIButton.makeIconicButton(imageName: ImageName.cart, handler: goCart)
    
    private var screenNameLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addToCart: () -> Void = { [weak self] in
        self?.presenter.addProductToCart()
    }
    private lazy var addToCartButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, handler: addToCart)

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
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupUiTexts()
    }
    
}

extension ProductViewController: ProductViewProtocol {
    
}
