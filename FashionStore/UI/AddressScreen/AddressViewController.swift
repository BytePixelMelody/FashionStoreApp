//
//  AddressViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

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
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var someTextFieldEditedFlag = false
    
    private lazy var backScreenAction: () -> Void = { [weak self] in
        guard let self else { return }
        presenter.backScreen(someTextFieldEdited: someTextFieldEditedFlag)
    }

    private lazy var closableHeaderView = HeaderNamedView(backScreenAction: backScreenAction, headerTitle: Self.headerTitle)
    
    private let addressScrollView = UIScrollView.makeScrollView()
    
    // stack view
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
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var lastNameTextField = UITextFieldStyled(
        placeholder: Self.lastNameTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var addressTextField = UITextFieldStyled(
        placeholder: Self.addressTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var cityTextField = UITextFieldStyled(
        placeholder: Self.cityTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var stateTextField = UITextFieldStyled(
        placeholder: Self.stateTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var zipCodeTextField = UITextFieldStyled(
        placeholder: Self.zipCodeTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var countryTextField = UITextFieldStyled(
        placeholder: Self.countryTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var phoneNumberTextField = UITextFieldStyled(
        placeholder: Self.phoneNumberTextFieldPlaceholder,
        keyboardType: .phonePad,
        dataIsSensitive: true
    )

    private lazy var addAddressButton = UIButton.makeDarkButton(imageName: ImageName.plusDark) // action by Combine
    private lazy var saveAddressButton = UIButton.makeDarkButton() // action by Combine
    
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
        arrangeLayout()
        textFieldsChaining()
        makeAddOrSaveButtonPublisher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // check address and fill
        presenter.addressScreenWillAppear()
        
        // making publisher to check if there are any changes
        makeTextFieldsPublisher()
    }
    
    private func setupUiTexts() {
        addAddressButton.configuration?.attributedTitle = AttributedString(Self.addAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
        saveAddressButton.configuration?.attributedTitle = AttributedString(Self.saveAddressButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setupUiTexts()
        }
    }
    
    // creating a line image
    private func createLineGray() -> UIImageView {
       let imageView = UIImageView(image: UIImage(named: ImageName.lineGray))
        // no vertical scale
        imageView.setContentHuggingPriority(.required, for: .vertical)
        return imageView
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
  
    private func arrangeLayout() {
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
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
        
    private func arrangeSaveAddressButton() {
        view.addSubview(saveAddressButton)
        saveAddressButton.snp.makeConstraints { make in
            // medium - for keyboard appearance priority
            make.top.equalTo(addressScrollView.snp.bottom).offset(8).priority(.medium)
            make.left.right.bottom.equalToSuperview().inset(34)
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
    private func textFieldsChaining() {
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
    private func hideKeyboard() {
        view.endEditing(false)
    }
    
    // configure publishers using framework CombineCocoa
    private func makeAddOrSaveButtonPublisher() {
        // saveAddressButton or addAddressButton tapped
        let addOrSaveTapped = Publishers.Merge(
            saveAddressButton.controlEventPublisher(for: .primaryActionTriggered),
            addAddressButton.controlEventPublisher(for: .primaryActionTriggered)
        )
        
        // call presenter.saveChanges
        addOrSaveTapped
            .sink { [weak self] in
                guard let self else { return }
                presenter.saveChanges(
                    someTextFieldEdited: someTextFieldEditedFlag,
                    firstName:   firstNameTextField.text,
                    lastName:    lastNameTextField.text,
                    address:     addressTextField.text,
                    city:        cityTextField.text,
                    state:       stateTextField.text,
                    zipCode:     zipCodeTextField.text,
                    country:     countryTextField.text,
                    phoneNumber: phoneNumberTextField.text
                )
            }
            .store(in: &cancellables)
    }
    
    // make publisher to check if there are any edits in text fields
    private func makeTextFieldsPublisher() {
        // initial values of text fields
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let address = addressTextField.text,
              let city = cityTextField.text,
              let state = stateTextField.text,
              let zipCode = zipCodeTextField.text,
              let country = countryTextField.text,
              let phoneNumber = phoneNumberTextField.text
        else {
            return
        }
        
        // flag - if text field was edited
        var firstNameEdited   = false
        var lastNameEdited    = false
        var addressEdited     = false
        var cityEdited        = false
        var stateEdited       = false
        var zipCodeEdited     = false
        var countryEdited     = false
        var phoneNumberEdited = false
        
        // if the entered value differs from the initial one than edited flag = true
        firstNameTextField.textPublisher
            .map { firstName != $0 }
            .sink { firstNameEdited = $0 }
            .store(in: &cancellables)
        lastNameTextField.textPublisher
            .map { lastName != $0 }
            .sink { lastNameEdited = $0 }
            .store(in: &cancellables)
        addressTextField.textPublisher
            .map { address != $0 }
            .sink { addressEdited = $0 }
            .store(in: &cancellables)
        cityTextField.textPublisher
            .map { city != $0 }
            .sink { cityEdited = $0 }
            .store(in: &cancellables)
        stateTextField.textPublisher
            .map { state != $0 }
            .sink { stateEdited = $0 }
            .store(in: &cancellables)
        zipCodeTextField.textPublisher
            .map { zipCode != $0 }
            .sink { zipCodeEdited = $0 }
            .store(in: &cancellables)
        countryTextField.textPublisher
            .map { country != $0 }
            .sink { countryEdited = $0 }
            .store(in: &cancellables)
        phoneNumberTextField.textPublisher
            .map { phoneNumber != $0 }
            .sink { phoneNumberEdited = $0 }
            .store(in: &cancellables)

        // any text field edit
        let anyEdits = Publishers.Merge8(
            firstNameTextField.textPublisher,
            lastNameTextField.textPublisher,
            addressTextField.textPublisher,
            cityTextField.textPublisher,
            stateTextField.textPublisher,
            zipCodeTextField.textPublisher,
            countryTextField.textPublisher,
            phoneNumberTextField.textPublisher
        )
        
        // if any text field was edited, than self edited flag = true
        anyEdits
            .sink { [weak self] _ in
                guard let self else { return }
                someTextFieldEditedFlag = (firstNameEdited || lastNameEdited || addressEdited || cityEdited || stateEdited || zipCodeEdited || countryEdited || phoneNumberEdited)
            }
            .store(in: &cancellables)
    }
    
}

extension AddressViewController: AddressViewProtocol {
    
    func showAddAddressButton() {
        addAddressButton.isHidden = false
        saveAddressButton.isHidden = true
    }
    
    func showSaveAddressButton() {
        addAddressButton.isHidden = true
        saveAddressButton.isHidden = false
    }
    
    // filling text fields by text
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
