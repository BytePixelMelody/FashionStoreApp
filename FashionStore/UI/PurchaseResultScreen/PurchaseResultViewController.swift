//
//  PurchaseResultViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 14.04.2023.
//

import UIKit
import SnapKit

protocol PurchaseResultViewProtocol: AnyObject {
    func dismissView()
}

class PurchaseResultViewController: UIViewController {
    private static let successHeaderTitle = "Success"
    private static let thankYouLabelText = "Thank you for your purchase"
    private static let receiptLabelText = "Payment receipt: "
    private static let storeButtonTitle = "Back to store"

    private let presenter: PurchaseResultPresenterProtocol
    private let receiptNumber: String
    
    private var popupView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        return view
    }()
    
    private var verticalStackView = UIStackView.makeVerticalStackView(alignment: .center)
    
    private lazy var closeScreenAction: () -> Void = { [weak self] in
        self?.presenter.goStoreScreen()
    }
    
    private lazy var closableHeaderView = HeaderNamedView(closeScreenHandler: closeScreenAction, headerTitle: Self.successHeaderTitle)

    private let successImage = UIImageView(image: UIImage(named: ImageName.success))
    private let thankYouLabel = UILabel.makeLabel(numberOfLines: 0)
    private let receiptLabel = UILabel.makeLabel(numberOfLines: 0)
    private lazy var backToStoreButton = UIButton.makeDarkButton(handler: closeScreenAction)

    init(presenter: PurchaseResultPresenterProtocol, receiptNumber: String) {
        self.presenter = presenter
        self.receiptNumber = receiptNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black.withAlphaComponent(0.8)
        
        setupUiTexts()
        arrangeUiElements()
    }
    
    private func setupUiTexts() {
        thankYouLabel.attributedText = Self.thankYouLabelText.setStyle(style: .infoLargeCentered)
        receiptLabel.attributedText = (Self.receiptLabelText + receiptNumber).setStyle(style: .activeMediumCentered)
        backToStoreButton.configuration?.attributedTitle = AttributedString(Self.storeButtonTitle.uppercased().setStyle(style: .buttonDark))
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    

    private func arrangeUiElements() {
        view.addSubview(popupView)
        popupView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
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
        
        verticalStackView.addArrangedSubview(successImage)
        verticalStackView.setCustomSpacing(33, after: successImage)
        verticalStackView.addArrangedSubview(thankYouLabel)
        verticalStackView.setCustomSpacing(3, after: thankYouLabel)
        verticalStackView.addArrangedSubview(receiptLabel)
        verticalStackView.setCustomSpacing(45, after: receiptLabel)
        verticalStackView.addArrangedSubview(backToStoreButton)
        
        backToStoreButton.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(18)
            make.height.equalTo(50)
        }
    }
    
}

extension PurchaseResultViewController: PurchaseResultViewProtocol {
    func dismissView() {
        self.dismiss(animated: true)
    }
}
