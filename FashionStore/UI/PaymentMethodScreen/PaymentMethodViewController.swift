//
//  PaymentMethodViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol PaymentMethodViewProtocol: AnyObject {
    
}

class PaymentMethodViewController: UIViewController {
    private static let headerTitle = "Payment method"
    private static let nameOnCardTextFieldPlaceholder = "Name On Card"
    private static let cardNumberTextFieldPlaceholder = "Card Number"
    private static let expMonthTextFieldPlaceholder = "Exp Month"
    private static let expYearTextFieldPlaceholder = "Exp Year"
    private static let cvvTextFieldPlaceholder = "CVV"
    private static let addCardButtonTitle = "Add card"

    private let presenter: PaymentMethodPresenterProtocol
    
    private lazy var closeScreen: () -> Void = { [weak self] in
        self?.presenter.closeScreen()
    }
    private lazy var closeButton = UIButton.makeIconicButton(imageName: ImageName.close, handler: closeScreen)
    
    private var headerLabel = UILabel.makeLabel(numberOfLines: 1)
    
    private let spacerImage = UIImageView(image: UIImage(named: ImageName.spacer))
    
    private lazy var addCardButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, handler: closeScreen)
  
    init(presenter: PaymentMethodPresenterProtocol) {
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
        addCardButton.configuration?.attributedTitle = AttributedString(Self.addCardButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    private func arrangeUiElements() {
        arrangeCloseButton()
        arrangeHeaderLabel()
        arrangeSpacerImage()
        arrangeAddCardButton()
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
    
    private func arrangeAddCardButton() {
        view.addSubview(addCardButton)
        addCardButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
}

extension PaymentMethodViewController: PaymentMethodViewProtocol {
    
}
