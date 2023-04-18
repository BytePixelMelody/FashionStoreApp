//
//  ErrorMessageViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 17.04.2023.
//

import UIKit
import SnapKit

protocol ErrorMessageViewProtocol: AnyObject {
    
}

class ErrorMessageViewController: UIViewController {
    
    private static let headerTitle = "Sorry"
    private static let defaultErrorButtonTitle = "OK"

    // properties for init
    private let presenter: ErrorMessagePresenterProtocol
    private let errorLabelText: String
    private var errorAction: (() -> Void)?
    private var errorButtonTitle: String?
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.addGestureRecognizer(backgroundTap)
        return view
    }()
    
    private lazy var backgroundTap = UITapGestureRecognizer(target: self, action: #selector(closeScreen))
    
    private var popupView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.closeErrorMessageScreen()
    }
    
    private lazy var closableHeaderView = HeaderNamedView(closeScreenHandler: closeScreenAction, headerTitle: Self.headerTitle)
    
    private var verticalStackView = UIStackView.makeVerticalStackView(alignment: .center)

    private let smileDisappointedImage = UIImageView.makeImageView(imageName: ImageName.smileDisappointed, width: 35, height: 35, contentMode: .scaleAspectFit)
    
    private let errorLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var errorButton = UIButton.makeDarkButton(handler: errorAction)

    init(
        presenter: ErrorMessagePresenterProtocol,
        errorLabelText: String,
        errorAction: (() -> Void)?,
        errorButtonTitle: String?
    ) {
        self.presenter = presenter
        self.errorLabelText = errorLabelText
        self.errorAction = errorAction
        self.errorButtonTitle = errorButtonTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkErrorButtonState()
        setupUiTexts()
        arrangeUiElements()
    }
    
    @objc
    func closeScreen() {
        closeScreenAction()
    }
    
    // default action and text if button has nil values
    private func checkErrorButtonState() {
        if errorAction == nil {
            errorAction = closeScreenAction
        }
        
        if errorButtonTitle == nil {
            errorButtonTitle = Self.defaultErrorButtonTitle
        }
    }
    
    private func setupUiTexts() {
        errorLabel.attributedText = errorLabelText.setStyle(style: .infoLargeCentered)
        if let errorButtonTitle {
            errorButton.configuration?.attributedTitle = AttributedString(errorButtonTitle.uppercased().setStyle(style: .buttonDark))
        }
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
            make.top.equalTo(closableHeaderView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(34)
        }
        
        verticalStackView.addArrangedSubview(smileDisappointedImage)
        verticalStackView.setCustomSpacing(29, after: smileDisappointedImage)
        verticalStackView.addArrangedSubview(errorLabel)
        verticalStackView.setCustomSpacing(45, after: errorLabel)
        verticalStackView.addArrangedSubview(errorButton)
        
        errorButton.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(18)
            make.height.equalTo(50)
        }
    }
    
}

extension ErrorMessageViewController: ErrorMessageViewProtocol {
    
}
