//
//  AddressViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol AddressViewProtocol: AnyObject {
    
}

class AddressViewController: UIViewController {
    private static let headerTitle = "Shipping Address"
    private static let firstNameTextFieldPlaceholder = "First name"
    private static let lastNameTextFieldPlaceholder = "Last name"
    private static let addressTextFieldPlaceholder = "Address"
    private static let cityTextFieldPlaceholder = "City"
    private static let stateTextFieldPlaceholder = "State"
    private static let zipCodeTextFieldPlaceholder = "ZIP code"
    private static let phoneNumberTextFieldPlaceholder = "Phone Number"
    private static let saveAddressButtonTitle = "Save address"
    
    private let presenter: AddressPresenterProtocol
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }

    private lazy var closableHeaderView = HeaderNamedView(backScreenHandler: closeScreenAction, headerTitle: Self.headerTitle)
    
    private let addressScrollView = UIScrollView.makeScrollView()
    
    private let addressStackView = UIStackView.makeVerticalStackView(spacing: 5.0)
   
    private let fooTexField = UITextFieldWithInsets.makeTextFieldWithInsets(textInsets: UIEdgeInsets(
        top: 10.0, left: 20.0, bottom: 10.0, right: 0.0
    ))
    
    private lazy var saveChangesAction: () -> Void = { [weak self] in
        self?.presenter.saveChanges()
    }

    private lazy var saveAddressButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, handler: saveChangesAction)
    
    init(presenter: AddressPresenterProtocol) {
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
        fillAddressStackView()
        arrangeUiElements()
    }
    
    private func setupUiTexts() {
        saveAddressButton.configuration?.attributedTitle = AttributedString(Self.saveAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
        fooTexField.attributedPlaceholder = NSLocalizedString(Self.firstNameTextFieldPlaceholder, comment:
            Self.firstNameTextFieldPlaceholder).setStyle(style: .bodyLarge)
        fooTexField.defaultTextAttributes[.font] = TextStyle.bodyLarge.fontMetrics.scaledFont(for: TextStyle.bodyLarge.font)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func fillAddressStackView() {
        addressStackView.addArrangedSubview(fooTexField)
        addressStackView.setCustomSpacing(29, after: fooTexField)
    }
  
    private func arrangeUiElements() {
        arrangeClosableHeaderView()
        arrangeAddressScrollView()
        arrangeAddressStackView()
        arrangeAddAddressButton()
    }
    
    private func arrangeClosableHeaderView() {
        view.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeAddressScrollView() {
        view.addSubview(addressScrollView)
        addressScrollView.snp.makeConstraints { make in
            make.top.equalTo(closableHeaderView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.width.equalTo(addressScrollView.contentLayoutGuide.snp.width)
            // bottom is in button constraints
        }
    }
    
    private func arrangeAddressStackView() {
        addressScrollView.addSubview(addressStackView)
        addressStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(addressScrollView.contentLayoutGuide)
            make.left.right.equalTo(addressScrollView.contentLayoutGuide).inset(16)
        }
    }
    
    private func arrangeAddAddressButton() {
        view.addSubview(saveAddressButton)
        saveAddressButton.snp.makeConstraints { make in
            make.top.equalTo(addressScrollView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
      
}

extension AddressViewController: AddressViewProtocol {
    
}
