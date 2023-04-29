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
    
    // full stack
    private let fullAddressVerticalStackView = UIStackView.makeVerticalStackView()
    
    // 2 columns: first name, last name
    private let fullNameHorizontalStackView = UIStackView.makeHorizontalStackView(spacing: 12.0, distribution: .fillEqually)
    private let firstNameVerticalStackView = UIStackView.makeVerticalStackView()
    private let lastNameVerticalStackView = UIStackView.makeVerticalStackView()
    
    // 2 columns: state, zip
    private let stateZipCodeHorizontalStackView = UIStackView.makeHorizontalStackView(spacing: 12.0, distribution: .fillEqually)
    private let stateVerticalStackView = UIStackView.makeVerticalStackView()
    private let zipCodeVerticalStackView = UIStackView.makeVerticalStackView()

    private lazy var firstNameTextField = UITextFieldStyled(placeholder: Self.firstNameTextFieldPlaceholder, frame: .zero)
    private lazy var lastNameTextField = UITextFieldStyled(placeholder: Self.lastNameTextFieldPlaceholder, frame: .zero)
    private lazy var addressTextField = UITextFieldStyled(placeholder: Self.addressTextFieldPlaceholder, frame: .zero)
    private lazy var cityTextField = UITextFieldStyled(placeholder: Self.cityTextFieldPlaceholder, frame: .zero)
    private lazy var stateTextField = UITextFieldStyled(placeholder: Self.stateTextFieldPlaceholder, frame: .zero)
    private lazy var zipCodeTextField = UITextFieldStyled(placeholder: Self.zipCodeTextFieldPlaceholder, frame: .zero)
    private lazy var phoneNumberTextField = UITextFieldStyled(placeholder: Self.phoneNumberTextFieldPlaceholder, frame: .zero)
    
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
        fillStackViews()
        arrangeUiElements()
    }
    
    private func setupUiTexts() {
        saveAddressButton.configuration?.attributedTitle = AttributedString(Self.saveAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    // creating a line image
    private func createLineGray() -> UIImageView {
       UIImageView(image: UIImage(named: ImageName.lineGray))
    }
    
    private func fillStackViews() {
        // 2 columns row: first name, last name
        fullAddressVerticalStackView.addArrangedSubview(fullNameHorizontalStackView)
        // first name column
        fullNameHorizontalStackView.addArrangedSubview(firstNameVerticalStackView)
        firstNameVerticalStackView.addArrangedSubview(firstNameTextField)
        firstNameVerticalStackView.addArrangedSubview(createLineGray())
        // last name column
        fullNameHorizontalStackView.addArrangedSubview(lastNameVerticalStackView)
        lastNameVerticalStackView.addArrangedSubview(lastNameTextField)
        lastNameVerticalStackView.addArrangedSubview(createLineGray())
        // custom spacing
        fullAddressVerticalStackView.setCustomSpacing(5, after: fullNameHorizontalStackView)

        // address row
        fullAddressVerticalStackView.addArrangedSubview(addressTextField)
        let addressUnderline = createLineGray()
        fullAddressVerticalStackView.addArrangedSubview(addressUnderline)
        // custom spacing
        fullAddressVerticalStackView.setCustomSpacing(5, after: addressUnderline)
        
        // city row
        fullAddressVerticalStackView.addArrangedSubview(cityTextField)
        let cityUnderline = createLineGray()
        fullAddressVerticalStackView.addArrangedSubview(cityUnderline)
        // custom spacing
        fullAddressVerticalStackView.setCustomSpacing(5, after: cityUnderline)

        // 2 columns row: state, zip
        fullAddressVerticalStackView.addArrangedSubview(stateZipCodeHorizontalStackView)
        // state column
        stateZipCodeHorizontalStackView.addArrangedSubview(stateVerticalStackView)
        stateVerticalStackView.addArrangedSubview(stateTextField)
        stateVerticalStackView.addArrangedSubview(createLineGray())
        // zip column
        stateZipCodeHorizontalStackView.addArrangedSubview(zipCodeVerticalStackView)
        zipCodeVerticalStackView.addArrangedSubview(zipCodeTextField)
        zipCodeVerticalStackView.addArrangedSubview(createLineGray())
        // custom spacing
        fullAddressVerticalStackView.setCustomSpacing(5, after: stateZipCodeHorizontalStackView)

        // phone number row
        fullAddressVerticalStackView.addArrangedSubview(phoneNumberTextField)
        fullAddressVerticalStackView.addArrangedSubview(createLineGray())
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
        addressScrollView.addSubview(fullAddressVerticalStackView)
        fullAddressVerticalStackView.snp.makeConstraints { make in
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
