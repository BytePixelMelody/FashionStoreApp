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
    private let deleteInfoAction: () -> Void
    
    private lazy var editInfoTap = UITapGestureRecognizer(target: self, action: #selector(editInfoSelector))
    private lazy var deleteInfoButton = UIButton.makeIconicButton(imageName: ImageName.trash, action: deleteInfoAction)

    // creating stack view
    private let horizontalStackView = UIStackView.makeHorizontalStackView(spacing: 12, alignment: .center)

    // creating a payment system image
    private lazy var paymentSystemImageView = UIImageView.makeImageView(imageName: paymentSystemImageName,
                                                                    width: 52,
                                                                    height: 52,
                                                                    contentMode: .scaleAspectFit)

    // creating a label
    private let cardInfoLabel = UILabel.makeLabel(numberOfLines: 0)

    // creating a line image
    private let lineImage = UIImageView(image: UIImage(named: ImageName.lineGray))

    init(
        paymentSystemImageName: String,
        paymentSystemName: String,
        cardLastDigits: String,
        editInfoAction: @escaping () -> Void,
        deleteInfoAction: @escaping () -> Void,
        frame: CGRect = .zero
    ) {
        self.paymentSystemImageName = paymentSystemImageName
        self.paymentSystemName = paymentSystemName
        self.cardLastDigits = cardLastDigits
        self.editInfoAction = editInfoAction
        self.deleteInfoAction = deleteInfoAction
        super.init(frame: frame)
        
        // adding tap
        self.addGestureRecognizer(editInfoTap)

        // setup typography texts
        setupUiTexts()
        
        // arrange elements
        arrangeLayout()
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
        
        cardInfoLabel.attributedText = cardInfoLabelText.setStyle(style: .bodyMediumDark)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func arrangeLayout() {
        
        self.addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.left.equalToSuperview().inset(18)
            make.right.equalToSuperview().inset(8)
        }
        
        // adding vertical stack view for labels to horizontal stack view
        horizontalStackView.addArrangedSubview(paymentSystemImageView)
        horizontalStackView.addArrangedSubview(cardInfoLabel)
        horizontalStackView.addArrangedSubview(deleteInfoButton)
        
        deleteInfoButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        // adding bottom line to view
        self.addSubview(lineImage)
        lineImage.snp.makeConstraints { make in
            make.top.equalTo(horizontalStackView.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

}
