//
//  StartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol StoreViewProtocol: AnyObject {
    
}

class StoreViewController: UIViewController {
    private let presenter: StorePresenterProtocol

    private static let screenNameTitle = "Fashion\nStore"
    private static let toProductTitle = "TO PRODUCT"
    
    private var screenNameLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var goProduct: () -> Void = { [weak self] in
        self?.presenter.showProduct()
    }
    
    private lazy var toProductButton = UIButton.makeDarkButton(imageName: "TagDark", handler: goProduct)
    
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
        screenNameLabel.attributedText = Self.screenNameTitle.uppercased().setStyle(style: .titleLarge)
        toProductButton.configuration?.attributedTitle = AttributedString(Self.toProductTitle.setStyle(style: .buttonDark))
    }
    
    private func arrangeUiElements() {
        arrangeScreenNameLabel()
        arrangeToProductButton()
    }
    
    private func arrangeScreenNameLabel() {
        view.addSubview(screenNameLabel)
        screenNameLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func arrangeToProductButton() {
        view.addSubview(toProductButton)
        toProductButton.snp.makeConstraints { make in
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
        debugPrint("Accessibility settings was changed - scale font size on StoreViewController")
    }
    
}

extension StoreViewController: StoreViewProtocol {
    
}
