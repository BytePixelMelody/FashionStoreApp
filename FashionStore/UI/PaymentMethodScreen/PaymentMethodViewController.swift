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
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }
    
    private lazy var closableHeaderView = HeaderNamedView(backScreenHandler: closeScreenAction, headerTitle: Self.headerTitle)

    private lazy var addCardButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, handler: closeScreenAction)
  
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
        addCardButton.configuration?.attributedTitle = AttributedString(Self.addCardButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func arrangeUiElements() {
        arrangeClosableHeaderView()
        arrangeAddCardButton()
    }
    
    private func arrangeClosableHeaderView() {
        view.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
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
