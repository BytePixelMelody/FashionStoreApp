//
//  PaymentMethodViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

protocol PaymentMethodViewProtocol: AnyObject {
    func showAddPaymentMethodButton()
    func showSavePaymentMethodButton()
    func fillPaymentMethod(
        nameOnCard: String,
        cardNumber: String,
        expMonth: String,
        expYear: String,
        cvv: String
    )
}

final class PaymentMethodViewController: UIViewController {
    private static let headerTitle = "Payment method"
    private static let nameOnCardTextFieldPlaceholder = "Name On Card*"
    private static let cardNumberTextFieldPlaceholder = "Card Number*"
    private static let expMonthTextFieldPlaceholder = "Exp Month*"
    private static let expYearTextFieldPlaceholder = "Exp Year*"
    private static let cvvTextFieldPlaceholder = "CVV*"
    private static let addCardButtonTitle = "Add card"
    private static let saveCardButtonTitle = "Save card"

    private let presenter: PaymentMethodPresenterProtocol

    private var cancellables: Set<AnyCancellable> = []

    private var someTextFieldEditedFlag = false

    private lazy var backScreenAction: () -> Void = { [weak self] in
        guard let self else { return }
        presenter.backScreen(someTextFieldEdited: someTextFieldEditedFlag)
    }

    private lazy var closableHeaderView = HeaderNamedView(backScreenAction: backScreenAction, headerTitle: Self.headerTitle)

    private let paymentMethodScrollView = UIScrollView.makeScrollView()

    // stack view
    private let paymentMethodVerticalStackView = UIStackView.makeVerticalStackView()

    // 2 columns: Exp Month, Exp Year
    private let cardValidHorizontalStackView = UIStackView.makeHorizontalStackView(spacing: 12.0, distribution: .fillEqually)
    private let expMonthVerticalStackView = UIStackView.makeVerticalStackView()
    private let expYearVerticalStackView = UIStackView.makeVerticalStackView()

    private lazy var nameOnCardTextField = UITextFieldStyled(
        placeholder: Self.nameOnCardTextFieldPlaceholder,
        returnKeyType: .next,
        dataIsSensitive: true
    )
    private lazy var cardNumberTextField = UITextFieldStyled(
        placeholder: Self.cardNumberTextFieldPlaceholder,
        keyboardType: .numberPad,
        dataIsSensitive: true
    )
    private lazy var expMonthTextField = UITextFieldStyled(
        placeholder: Self.expMonthTextFieldPlaceholder,
        keyboardType: .numberPad,
        dataIsSensitive: true
    )
    private lazy var expYearTextField = UITextFieldStyled(
        placeholder: Self.expYearTextFieldPlaceholder,
        keyboardType: .numberPad,
        dataIsSensitive: true
    )
    private lazy var cvvTextField = UITextFieldStyled(
        placeholder: Self.cvvTextFieldPlaceholder,
        keyboardType: .numberPad,
        isSecureTextEntry: true,
        dataIsSensitive: true
    )

    private lazy var addCardButton = UIButton.makeDarkButton(imageName: ImageName.plusDark) // action by Combine
    private lazy var saveCardButton = UIButton.makeDarkButton() // action by Combine

    private lazy var backgroundTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))

    init(presenter: PaymentMethodPresenterProtocol) {
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
        // publisher to react on buttons tap
        addOrSaveButtonTapPublisher()
        // publisher check input format
        checkTextFieldsFormatsPublisher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // check address and fill
        presenter.paymentMethodWillAppear()

        // publisher to check any future text fields changes that are filled after previous method
        checkTextFieldsEditsPublisher()
    }

    private func setupUiTexts() {
        addCardButton.configuration?.attributedTitle = AttributedString(Self.addCardButtonTitle.uppercased().setStyle(style: .buttonDark))
        saveCardButton.configuration?.attributedTitle = AttributedString(Self.saveCardButtonTitle.uppercased().setStyle(style: .buttonDark))
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
       UIImageView(image: UIImage(named: ImageName.lineGray))
    }

    private func fillStackViews() {
        // name on card row
        paymentMethodVerticalStackView.addArrangedSubview(nameOnCardTextField)
        let nameOnCardUnderline = createLineGray()
        paymentMethodVerticalStackView.addArrangedSubview(nameOnCardUnderline)
        // custom spacing
        paymentMethodVerticalStackView.setCustomSpacing(5, after: nameOnCardUnderline)

        // card number row
        paymentMethodVerticalStackView.addArrangedSubview(cardNumberTextField)
        let cardNumberUnderline = createLineGray()
        paymentMethodVerticalStackView.addArrangedSubview(cardNumberUnderline)
        // custom spacing
        paymentMethodVerticalStackView.setCustomSpacing(5, after: cardNumberUnderline)

        // 2 columns row: state, zip
        paymentMethodVerticalStackView.addArrangedSubview(cardValidHorizontalStackView)
        // state column
        cardValidHorizontalStackView.addArrangedSubview(expMonthVerticalStackView)
        expMonthVerticalStackView.addArrangedSubview(expMonthTextField)
        expMonthVerticalStackView.addArrangedSubview(createLineGray())
        // zip column
        cardValidHorizontalStackView.addArrangedSubview(expYearVerticalStackView)
        expYearVerticalStackView.addArrangedSubview(expYearTextField)
        expYearVerticalStackView.addArrangedSubview(createLineGray())
        // custom spacing
        cardValidHorizontalStackView.setCustomSpacing(5, after: cardValidHorizontalStackView)

        // phone number row
        paymentMethodVerticalStackView.addArrangedSubview(cvvTextField)
        paymentMethodVerticalStackView.addArrangedSubview(createLineGray())
    }

    private func arrangeLayout() {
        arrangeClosableHeaderView()
        arrangePaymentMethodScrollView()
        arrangePaymentMethodStackView()
        arrangeAddCardButton()
        arrangeSaveCardButton()
        arrangeKeyboardLayoutGuide()
    }

    private func arrangeClosableHeaderView() {
        view.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func arrangePaymentMethodScrollView() {
        view.addSubview(paymentMethodScrollView)
        paymentMethodScrollView.snp.makeConstraints { make in
            make.top.equalTo(closableHeaderView.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
            make.width.equalTo(paymentMethodScrollView.contentLayoutGuide.snp.width)
            // bottom is in button constraints
        }
    }

    private func arrangePaymentMethodStackView() {
        paymentMethodScrollView.addSubview(paymentMethodVerticalStackView)
        paymentMethodVerticalStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(paymentMethodScrollView.contentLayoutGuide)
            make.left.right.equalTo(paymentMethodScrollView.contentLayoutGuide).inset(16)
        }
    }

    private func arrangeAddCardButton() {
        view.addSubview(addCardButton)
        addCardButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }

    private func arrangeSaveCardButton() {
        view.addSubview(saveCardButton)
        saveCardButton.snp.makeConstraints { make in
            // medium - for keyboard appearance priority
            make.top.equalTo(paymentMethodScrollView.snp.bottom).offset(8).priority(.medium)
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }

    // using keyboard layout
    private func arrangeKeyboardLayoutGuide() {
        paymentMethodScrollView.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).priority(.high)
        }
    }

    // chaining text fields to move from one to another by "Next" keyboard button
    private func textFieldsChaining() {
        nameOnCardTextField.addTarget(cardNumberTextField, action: #selector(becomeFirstResponder), for: .editingDidEndOnExit)
    }

    // hide keyboard
    @objc
    private func hideKeyboard() {
        view.endEditing(false)
    }

    // configure publishers using framework CombineCocoa
    private func addOrSaveButtonTapPublisher() {
        // saveAddressButton or addAddressButton tapped
        let addOrSaveTapped = Publishers.Merge(
            saveCardButton.controlEventPublisher(for: .primaryActionTriggered),
            addCardButton.controlEventPublisher(for: .primaryActionTriggered)
        )

        // call presenter.saveChanges
        addOrSaveTapped
            .sink { [weak self] in
                guard let self else { return }
                presenter.saveChanges(
                    someTextFieldEdited: someTextFieldEditedFlag,
                    nameOnCard: nameOnCardTextField.text,
                    cardNumber: cardNumberTextField.text,
                    expMonth: expMonthTextField.text,
                    expYear: expYearTextField.text,
                    cvv: cvvTextField.text
                )
            }
            .store(in: &cancellables)
    }

    // make publisher to check if there are any edits in text fields
    private func checkTextFieldsEditsPublisher() {
        // unwrapped initial values of text fields
        guard let nameOnCard = nameOnCardTextField.text,
              let cardNumber = cardNumberTextField.text,
              let expMonth = expMonthTextField.text,
              let expYear = expYearTextField.text,
              let cvv = cvvTextField.text
        else {
            return
        }

        // flag - if text field was edited
        var nameOnCardEdited = false
        var cardNumberEdited = false
        var expMonthEdited   = false
        var expYearEdited    = false
        var cvvEdited        = false

        // if the entered value differs from the initial one than edited flag = true
        nameOnCardTextField.textPublisher
            .map { nameOnCard != $0 }
            .sink { nameOnCardEdited = $0 }
            .store(in: &cancellables)
        cardNumberTextField.textPublisher
            .map { cardNumber != $0 }
            .sink { cardNumberEdited = $0 }
            .store(in: &cancellables)
        expMonthTextField.textPublisher
            .map { expMonth != $0 }
            .sink { expMonthEdited = $0 }
            .store(in: &cancellables)
        expYearTextField.textPublisher
            .map { expYear != $0 }
            .sink { expYearEdited = $0 }
            .store(in: &cancellables)
        cvvTextField.textPublisher
            .map { cvv != $0 }
            .sink { cvvEdited = $0 }
            .store(in: &cancellables)

        // any text field edit
        let anyEdits = Publishers.Merge5(
            nameOnCardTextField.textPublisher,
            cardNumberTextField.textPublisher,
            expMonthTextField.textPublisher,
            expYearTextField.textPublisher,
            cvvTextField.textPublisher
        )

        // if any text field was edited, than self edited flag = true
        anyEdits
            .sink { [weak self] _ in
                guard let self else { return }
                someTextFieldEditedFlag = (nameOnCardEdited || cardNumberEdited || expMonthEdited || expYearEdited || cvvEdited)
            }
            .store(in: &cancellables)
    }

    // make publisher to check correct input format in text fields
    private func checkTextFieldsFormatsPublisher() {
        // correct card number
        cardNumberTextField.textPublisher
            .compactMap { $0 } // nil is not streaming
            .map { text in // leave only digit characters from the string
                text.filter { character in
                    character.isNumber
                }
            }
            .compactMap { String($0.prefix(19)) } // only 19 first digits, China UnionPay have 16-19 digits
            .assign(to: \.text, on: cardNumberTextField) // cardNumberTextField.text = up to 19 digits
            .store(in: &cancellables)

        // correct month
        expMonthTextField.textPublisher
            .compactMap { $0 } // nil is not streaming
            .map { text in // leave only digit characters from the string
                text.filter { character in
                    character.isNumber
                }
            }
            .compactMap { String($0.prefix(2)) } // only 2 first digits
            .map { text in // not allow to input number > 12
                if let monthNumber = Int(text),
                    monthNumber > 12 {
                    return String(text.dropLast()) // 12 -> 12, 13 -> 1, 95 -> 9
                } else {
                    return text
                }
            }
            .assign(to: \.text, on: expMonthTextField) // expYearTextField.text = 2 digits
            .store(in: &cancellables)

        // correct year
        expYearTextField.textPublisher
            .compactMap { $0 } // nil is not streaming
            .map { text in // leave only digit characters from the string
                text.filter { character in
                    character.isNumber
                }
            }
            .compactMap { String($0.prefix(2)) } // only 2 first digits
            .assign(to: \.text, on: expYearTextField) // expYearTextField.text = 2 digits
            .store(in: &cancellables)

        // correct cvv code
        cvvTextField.textPublisher
            .compactMap { $0 } // nil is not streaming
            .map { text in // leave only digit characters from the string
                text.filter { character in
                    character.isNumber
                }
            }
            .compactMap { String($0.prefix(4)) } // only 4 first digits
            .assign(to: \.text, on: cvvTextField) // cvvTextField.text = 4 digits
            .store(in: &cancellables)
    }

}

extension PaymentMethodViewController: PaymentMethodViewProtocol {

    func showAddPaymentMethodButton() {
        addCardButton.isHidden = false
        saveCardButton.isHidden = true
    }

    func showSavePaymentMethodButton() {
        addCardButton.isHidden = true
        saveCardButton.isHidden = false
    }

    // filling text fields by text
    func fillPaymentMethod(
        nameOnCard: String,
        cardNumber: String,
        expMonth: String,
        expYear: String,
        cvv: String
    ) {
        nameOnCardTextField.text = nameOnCard
        cardNumberTextField.text = cardNumber
        expMonthTextField.text = expMonth
        expYearTextField.text = expYear
        cvvTextField.text = cvv
    }

}
