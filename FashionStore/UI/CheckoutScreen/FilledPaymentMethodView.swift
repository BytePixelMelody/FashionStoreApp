//
//  FilledPaymentMethodView.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.04.2023.
//

import UIKit

class FilledPaymentMethodView: UIView {
    
    // view image, labels texts, action from init
    private let paymentSystemImageName: String
    private let paymentSystemName: String
    private let cardLastDigits: String
    private let editInfoAction: () -> Void
    
    private lazy var editInfoTap = UITapGestureRecognizer(target: self, action: #selector(editInfoSelector))
    
    // creating stack views
    private let horizontalStackView = UIStackView.makeHorizontalStackView(spacing: 12, alignment: .center)

    // creating a payment system image
    private lazy var paymentSystemImage = UIImageView.makeImageView(imageName: paymentSystemImageName,
                                                                    width: 52,
                                                                    height: 52,
                                                                    contentMode: .scaleAspectFit)

    // creating a label
    private let cardInfoLabel = UILabel.makeLabel(numberOfLines: 0)

    // creating a forward image
    private let forwardImage = UIImageView(image: UIImage(named: ImageName.forward))

    // creating a line image
    private let lineImage = UIImageView(image: UIImage(named: ImageName.lineGray))

    init(
        paymentSystemImageName: String,
        paymentSystemName: String,
        cardLastDigits: String,
        editInfoAction: @escaping () -> Void,
        frame: CGRect = .zero
    ) {
        self.paymentSystemImageName = paymentSystemImageName
        self.paymentSystemName = paymentSystemName
        self.cardLastDigits = cardLastDigits
        self.editInfoAction = editInfoAction
        super.init(frame: frame)
        
        // adding tap
        self.addGestureRecognizer(editInfoTap)

        // setup typography texts
        setupUiTexts()
        
        // arrange elements
        arrangeUiElements()
    }
    
    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // called by tap on the view
    @objc
    private func editInfoSelector() {
        editInfoAction()
    }
    
    private func setupUiTexts() {
        let cardInfoLabelText = paymentSystemName + "  ••••" + cardLastDigits
        
        cardInfoLabel.attributedText = cardInfoLabelText.setStyle(style: .card)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func arrangeUiElements() {
        
        self.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.left.equalToSuperview().inset(18)
            make.right.equalToSuperview().inset(17)
        }
        
        // adding vertical stack view for labels to horizontal stack view
        horizontalStackView.addArrangedSubview(paymentSystemImage)
        horizontalStackView.addArrangedSubview(cardInfoLabel)
        horizontalStackView.addArrangedSubview(forwardImage)
        
        // disable forward image hugging and compression
        forwardImage.setContentHuggingPriority(.init(rawValue: 1000), for: .horizontal)
        forwardImage.setContentCompressionResistancePriority(.init(rawValue: 1000), for: .horizontal)
        
        // adding bottom line to view
        self.addSubview(lineImage)
        lineImage.snp.makeConstraints { make in
            make.top.equalTo(horizontalStackView.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

}
