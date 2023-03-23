//
//  StartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

// MARK: subviews: ClosableHeaderView, HeaderView, AddressGroupView, PaymentGroupView, PopUpView, FooterView 
// MARK: subviews: Collection Views with one presenter on screen, which communicates with subviews via ViewController
// MARK: stack views: AddressGroupView, PaymentGroupView, Chipping screen, Payment screen
// MARK: combine: filling fields of chipping and payment screens; presenter don't have links to subviews, it sends Publisher with data to ViewController that transfer it to subviews, view's Subscribers fill UI elements

import UIKit
import SnapKit

protocol StoreViewProtocol: AnyObject {
    
}

class StoreViewController: UIViewController {
    private static let screenNameTitle = "Fashion\nStore"
    private static let toProductTitle = "TO PRODUCT"
    
    private let presenter: StorePresenterProtocol
    
    private let logoImage = UIImageView(image: UIImage(named: ImageName.logo))
    
    private lazy var goCart: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    private lazy var goCartButton = UIButton.makeIconicButton(imageName: ImageName.cart, handler: goCart)

    private var screenNameLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var goProduct: () -> Void = { [weak self] in
        self?.presenter.showProduct()
    }
    
    private lazy var productButton = UIButton.makeDarkButton(imageName: ImageName.tagDark, handler: goProduct)
    
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
        productButton.configuration?.attributedTitle = AttributedString(Self.toProductTitle.setStyle(style: .buttonDark))
    }
    
    private func arrangeUiElements() {
        arrangeLogoImage()
        arrangeGoCartButton()
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
    
    private func arrangeToProductButton() {
        view.addSubview(productButton)
        productButton.snp.makeConstraints { make in
            make.top.equalTo(screenNameLabel.snp.bottom).offset(24)
            make.centerX.equalTo(screenNameLabel)
            make.height.equalTo(50)
            make.width.equalTo(210)
        }
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupUiTexts()
    }
    
}

extension StoreViewController: StoreViewProtocol {
    
}
