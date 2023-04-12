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
    private static let addAddressButtonTitle = "Add address"
    
    private let presenter: AddressPresenterProtocol
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }

    private lazy var closableHeaderView = HeaderNamedView(backScreenHandler: closeScreenAction, headerTitle: Self.headerTitle)
    
    private lazy var addAddressButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, handler: closeScreenAction)
    
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
        arrangeUiElements()
    }
    
    private func setupUiTexts() {
        addAddressButton.configuration?.attributedTitle = AttributedString(Self.addAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
  
    private func arrangeUiElements() {
        arrangeClosableHeaderView()
        arrangeAddAddressButton()
    }
    
    private func arrangeClosableHeaderView() {
        view.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeAddAddressButton() {
        view.addSubview(addAddressButton)
        addAddressButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
      
}

extension AddressViewController: AddressViewProtocol {
    
}
