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
    private var footerButtonAction: (() -> Void)?
    private var initCloseAction: (() -> Void)?
    
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .black.withAlphaComponent(0.8)
        backgroundView.addGestureRecognizer(backgroundTap)
        return backgroundView
    }()
    
    // if no close action passed by init - assign the default close action
    private lazy var closeAction: () -> Void = initCloseAction ?? { [weak self] in
        self?.presenter.closePopupScreen()
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

    private let image = UIImageView(image: UIImage(named: ImageName.success))
    private let messageLabel = UILabel.makeLabel(numberOfLines: 0)
    private var subMessageLabel: UILabel? = UILabel.makeLabel(numberOfLines: 0)
    
    // if no button action passed by init - assign the close action by default
    private lazy var footerButton = UIButton.makeDarkButton(action: footerButtonAction ?? closeAction)

    init(
        presenter: PopupPresenterProtocol,
        headerTitle: String,
        message: String,
        subMessage: String?,
        buttonTitle: String,
        buttonAction: (() -> Void)?,
        closeAction: (() -> Void)?
    ) {
        self.presenter = presenter
        self.headerTitle = headerTitle
        self.messageLabelText = message
        self.subMessageLabelText = subMessage
        self.footerButtonTitle = buttonTitle
        self.footerButtonAction = buttonAction
        self.initCloseAction = closeAction
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
