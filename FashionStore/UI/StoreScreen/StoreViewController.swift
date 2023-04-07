//
//  StartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

// TODO: FilledAddressView, FilledCardView
// TODO: HeaderView.swift - blank for standard header with Cart and menu/back button
// TODO: PopUpView
// TODO: replaceable ContainerView for AddressContainerView and PaymentContainerView in Checkout
// TODO: stack views: AddressGroupView, PaymentGroupView, ProductsView
// TODO: Chipping screen, Payment screen with stackView in scrollView for keyboard appearing support
// TODO: Collection Views with one presenter on screen, which communicates with subviews via ViewController
// TODO: combine: filling fields of chipping and payment screens; presenter don't have links to subviews, it sends Publisher with data to ViewController that transfer it to subviews, view's Subscribers fill UI elements

import UIKit
import SnapKit

protocol StoreViewProtocol: AnyObject {
    
}

class StoreViewController: UIViewController {
    private static let screenNameTitle = "Fashion\nStore"
    private static let toProductButtonTitle = "TO PRODUCT"
    
    private let presenter: StorePresenterProtocol
    
    private let logoImage = UIImageView(image: UIImage(named: ImageName.logo))
    
    private lazy var goCartAction: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    private lazy var cartButton = UIButton.makeIconicButton(imageName: ImageName.cart, handler: goCartAction)

    private let productsScrollView = UIScrollView.makeScrollView()

    private let screenNameLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var goProductAction: () -> Void = { [weak self] in
        self?.presenter.showProduct()
    }
    
    private lazy var productButton = UIButton.makeDarkButton(imageName: ImageName.tagDark, handler: goProductAction)
    
    init(presenter: StorePresenterProtocol) {
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
        productButton.configuration?.attributedTitle = AttributedString(Self.toProductButtonTitle.setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeLogoImage()
        arrangeCartButton()
        arrangeProductsScrollView()
        arrangeScreenNameLabel()
        arrangeToProductButton()
    }
    
    private func arrangeLogoImage() {
        view.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeCartButton() {
        view.addSubview(cartButton)
        cartButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeProductsScrollView() {
        view.addSubview(productsScrollView)
        productsScrollView.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
        productsScrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(productsScrollView.frameLayoutGuide.snp.width)
        }
        // contentLayoutGuide must have top and bottom constraints
    }

    private func arrangeScreenNameLabel() {
        productsScrollView.addSubview(screenNameLabel)
        
        screenNameLabel.snp.makeConstraints { make in
            make.top.equalTo(productsScrollView.contentLayoutGuide.snp.top).offset(300)
            make.centerX.equalTo(productsScrollView.contentLayoutGuide)
        }
    }
    
    private func arrangeToProductButton() {
        productsScrollView.addSubview(productButton)
        productButton.snp.makeConstraints { make in
            make.top.equalTo(screenNameLabel.snp.bottom).offset(24)
            make.centerX.equalTo(screenNameLabel)
            make.height.equalTo(50)
            make.width.equalTo(210)
            make.bottom.equalTo(productsScrollView.contentLayoutGuide.snp.bottom).inset(50)
        }
    }
    
}

extension StoreViewController: StoreViewProtocol {
    
}
