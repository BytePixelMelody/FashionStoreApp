//
//  PurchaseResultViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 14.04.2023.
//

import UIKit
import SnapKit

protocol PopupViewProtocol: AnyObject {
    
}

class PopupViewController: UIViewController {

    // properties for init
    private let presenter: PopupPresenterProtocol
    private let headerTitle: String 
    private let messageLabelText: String 
    private let subMessageLabelText: String?
    private let footerButtonTitle: String
    private var initButtonAction: (() -> Void)?
    private var initCloseAction: (() -> Void)?
    private let image: UIImageView

    private lazy var backgroundView: UIView = {
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .black.withAlphaComponent(0.8)
        backgroundView.addGestureRecognizer(backgroundTap)
        return backgroundView
    }()
    
    private lazy var closeAction: () -> Void = { [weak self] in
        guard let self else { return }
        // close self screen
        presenter.closePopupScreen()
        // if no close action passed by init - keep only close self action
        guard let initCloseAction else { return }
        initCloseAction()
    }

    private lazy var buttonAction: () -> Void = { [weak self] in
        guard let self else { return }
        // close self screen
        presenter.closePopupScreen()
        // if no other action passed by init - keep only close self action
        guard let initButtonAction else { return }
        initButtonAction()
    }
        
    private lazy var backgroundTap = UITapGestureRecognizer(target: self, action: #selector(closeScreen))
    
    private var popupView: UIView = {
        let popupView = UIView(frame: .zero)
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 20
        return popupView
    }()
    
    private lazy var closableHeaderView = HeaderNamedView(closeScreenAction: closeAction, headerTitle: headerTitle)
    
    private var verticalStackView = UIStackView.makeVerticalStackView(alignment: .center)

    private let messageLabel = UILabel.makeLabel(numberOfLines: 0)
    private var subMessageLabel: UILabel? = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var footerButton = UIButton.makeDarkButton(action: buttonAction)

    init(
        presenter: PopupPresenterProtocol,
        headerTitle: String,
        message: String,
        subMessage: String?,
        buttonTitle: String,
        buttonAction: (() -> Void)?,
        closeAction: (() -> Void)?,
        image: UIImageView // = UIImageView.makeImageView(imageName: ImageName.message)
    ) {
        self.presenter = presenter
        self.headerTitle = headerTitle
        self.messageLabelText = message
        self.subMessageLabelText = subMessage
        self.footerButtonTitle = buttonTitle
        self.initButtonAction = buttonAction
        self.initCloseAction = closeAction
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUiTexts()
        arrangeUiElements()
    }
    
    @objc
    func closeScreen() {
        closeAction()
    }
    
    private func setupUiTexts() {
        messageLabel.attributedText = messageLabelText.setStyle(style: .infoLargeCentered)
        if let subMessageLabelText {
            subMessageLabel?.attributedText = subMessageLabelText.setStyle(style: .activeMediumCentered)
        } else {
            subMessageLabel = nil
        }
        footerButton.configuration?.attributedTitle = AttributedString(footerButtonTitle.uppercased().setStyle(style: .buttonDark))
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    

    private func arrangeUiElements() {
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(popupView)
        popupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.centerY.equalTo(view.safeAreaLayoutGuide)
            make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(24)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        popupView.addSubview(closableHeaderView)
        closableHeaderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        popupView.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(closableHeaderView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(34)
        }
        
        verticalStackView.addArrangedSubview(image)
        verticalStackView.setCustomSpacing(33, after: image)
        verticalStackView.addArrangedSubview(messageLabel)
        verticalStackView.setCustomSpacing(3, after: messageLabel)
        if let subMessageLabel {
            verticalStackView.addArrangedSubview(subMessageLabel)
            verticalStackView.setCustomSpacing(45, after: subMessageLabel)
        } else {
            verticalStackView.setCustomSpacing(45, after: messageLabel)
        }
        verticalStackView.addArrangedSubview(footerButton)
        
        footerButton.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(18)
            make.height.equalTo(50)
        }
    }
    
}

extension PopupViewController: PopupViewProtocol {

}
