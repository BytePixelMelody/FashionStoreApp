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
    private let presenter: ProductPresenterProtocol
    
    private static let screenNameTitle = "Product\nView\nController"
    
    private var screenNameLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var goBack: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }
 
    private lazy var goCart: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    
    private lazy var goBackButton = UIButton.makeIconicButton(imageName: "BackLight", handler: goBack)
    
    private lazy var goCartButton = UIButton.makeIconicButton(imageName: "CartLight", handler: goCart)

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
        screenNameLabel.attributedText = Self.screenNameTitle.uppercased().setStyle(style: .titleLarge)
    }
    
    private func arrangeUiElements() {
        arrangeGoBackButton()
        arrangeScreenNameLabel()
        arrangeGoCartButton()
    }
    
    private func arrangeGoBackButton() {
        view.addSubview(goBackButton)
        goBackButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.left.equalTo(view.safeAreaLayoutGuide).offset(6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeScreenNameLabel() {
        view.addSubview(screenNameLabel)
        screenNameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
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

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupUiTexts()
        debugPrint("Accessibility settings was changed - scale font size on ProductViewController")
    }
    
}

extension ProductViewController: ProductViewProtocol {
    
}
