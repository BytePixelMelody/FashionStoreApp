//
//  AddressViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol AddressViewProtocol: AnyObject {
    func showAddAddressButton()
    func showSaveAddressButton()
    func fillAddress(
        firstName: String,
        lastName: String,
        address: String,
        city: String,
        state: String,
        zipCode: String,
        country: String,
        phoneNumber: String
    )
}

class AddressViewController: UIViewController {
    private static let headerTitle = "Shipping Address"
    private static let firstNameTextFieldPlaceholder = "First name*"
    private static let lastNameTextFieldPlaceholder = "Last name*"
    private static let addressTextFieldPlaceholder = "Address*"
    private static let cityTextFieldPlaceholder = "City*"
    private static let stateTextFieldPlaceholder = "State"
    private static let zipCodeTextFieldPlaceholder = "ZIP code*"
    private static let countryTextFieldPlaceholder = "Country*"
    private static let phoneNumberTextFieldPlaceholder = "Phone Number*"
    private static let addAddressButtonTitle = "Add address"
    private static let saveAddressButtonTitle = "Save address"
    
    private let presenter: AddressPresenterProtocol
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }

    private lazy var closableHeaderView = HeaderNamedView(backScreenAction: closeScreenAction, headerTitle: Self.headerTitle)
    
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

    private lazy var firstNameTextField = UITextFieldStyled(
        placeholder: Self.firstNameTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var lastNameTextField = UITextFieldStyled(
        placeholder: Self.lastNameTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var addressTextField = UITextFieldStyled(
        placeholder: Self.addressTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var cityTextField = UITextFieldStyled(
        placeholder: Self.cityTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var stateTextField = UITextFieldStyled(
        placeholder: Self.stateTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var zipCodeTextField = UITextFieldStyled(
        placeholder: Self.zipCodeTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var countryTextField = UITextFieldStyled(
        placeholder: Self.countryTextFieldPlaceholder,
        returnKeyType: .next
    )
    private lazy var phoneNumberTextField = UITextFieldStyled(
        placeholder: Self.phoneNumberTextFieldPlaceholder,
        keyboardType: .phonePad
    )
    
    private lazy var saveChangesAction: () -> Void = { [weak self] in
        guard
            let firstName = self?.firstNameTextField.text,
            let lastName = self?.lastNameTextField.text,
            let address = self?.addressTextField.text,
            let city = self?.cityTextField.text,
            let state = self?.stateTextField.text,
            let zipCode = self?.zipCodeTextField.text,
            let country = self?.countryTextField.text,
            let phoneNumber = self?.phoneNumberTextField.text else {
            return
        }
        self?.presenter.saveChanges(
            firstName: firstName,
            lastName: lastName,
            address: address,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
            phoneNumber: phoneNumber
        )
    }

    private lazy var addAddressButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, action: saveChangesAction)
    private lazy var saveAddressButton = UIButton.makeDarkButton(action: saveChangesAction)
    
    private lazy var backgroundTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

    init(presenter: AddressPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide keyboard on background tap
        view.addGestureRecognizer(backgroundTap)
        view.backgroundColor = .white

        setupUiTexts()
        fillStackViews()
        arrangeUiElements()
        TextFieldsChaining()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check address
        presenter.addressScreenWillAppear()
    }
    
    private func setupUiTexts() {
        saveAddressButton.configuration?.attributedTitle = AttributedString(Self.saveAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
        addAddressButton.configuration?.attributedTitle = AttributedString(Self.addAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
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

        // country row
        fullAddressVerticalStackView.addArrangedSubview(countryTextField)
        let countryUnderline = createLineGray()
        fullAddressVerticalStackView.addArrangedSubview(countryUnderline)
        // custom spacing
        fullAddressVerticalStackView.setCustomSpacing(5, after: countryUnderline)

        // phone number row
        fullAddressVerticalStackView.addArrangedSubview(phoneNumberTextField)
        fullAddressVerticalStackView.addArrangedSubview(createLineGray())
    }
  
    private func arrangeUiElements() {
        arrangeClosableHeaderView()
        arrangeAddressScrollView()
        arrangeAddressStackView()
        arrangeAddAddressButton()
        arrangeSaveAddressButton()
        arrangeKeyboardLayoutGuide()
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
        view.addSubview(addAddressButton)
        addAddressButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(34)
            make.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
        
    private func arrangeSaveAddressButton() {
        view.addSubview(saveAddressButton)
        saveAddressButton.snp.makeConstraints { make in
            // for keyboard appearance support
            make.top.equalTo(addressScrollView.snp.bottom).offset(8).priority(.medium)
            make.left.right.equalToSuperview().inset(34)
            make.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
    // using keyboard layout
    private func arrangeKeyboardLayoutGuide() {
        addressScrollView.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).priority(.high)
        }
    }
    
    // chaining text fields to move from one to another by "Next" keyboard button
    private func TextFieldsChaining() {
        firstNameTextField.addTarget(lastNameTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        lastNameTextField.addTarget(addressTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        addressTextField.addTarget(cityTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        cityTextField.addTarget(stateTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        stateTextField.addTarget(zipCodeTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        zipCodeTextField.addTarget(countryTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
        countryTextField.addTarget(phoneNumberTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
    }
      
    // hide keyboard
    @objc
    func hideKeyboard() {
        view.endEditing(false)
    }
}

extension AddressViewController: AddressViewProtocol {
    
    func showAddAddressButton() {
        addAddressButton.isHidden = false
        saveAddressButton.isHidden = true
    }
    
    func showSaveAddressButton() {
        saveAddressButton.isHidden = false
        addAddressButton.isHidden = true
    }
    
    func fillAddress(
        firstName: String,
        lastName: String,
        address: String,
        city: String,
        state: String,
        zipCode: String,
        country: String,
        phoneNumber: String
    ) {
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        addressTextField.text = address
        cityTextField.text = city
        stateTextField.text = state
        zipCodeTextField.text = zipCode
        countryTextField.text = country
        phoneNumberTextField.text = phoneNumber
    }

}
