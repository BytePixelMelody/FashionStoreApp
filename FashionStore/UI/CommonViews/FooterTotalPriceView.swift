//
//  FooterTotalPriceView.swift
//  FashionStore
//
//  Created by Vyacheslav on 24.03.2023.
//

import UIKit

class FooterTotalPriceView: UIView {
    
    private let totalLabelTitle: String
    private let currencySign: String
    private let actionHandler: () -> Void
    private let buttonTitle: String
    
    private let lineImage = UIImageView(image: UIImage(named: ImageName.lineGray))
    private let totalLabel = UILabel.makeLabel(numberOfLines: 1)
    private let totalPriceLabel = UILabel.makeLabel(numberOfLines: 1)
    private lazy var button = UIButton.makeDarkButton(imageName: ImageName.cartDark, handler: actionHandler)
    
    init(
        totalLabelTitle: String,
        currencySign: String,
        actionHandler: @escaping () -> Void,
        buttonTitle: String,
        frame: CGRect = .zero
    ) {
        self.totalLabelTitle = totalLabelTitle
        self.currencySign = currencySign
        self.actionHandler = actionHandler
        self.buttonTitle = buttonTitle
        super.init(frame: frame)
        
        setupUiTexts()
        arrangeUiElements()
    }
   
    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUiTexts() {
        button.configuration?.attributedTitle = AttributedString(buttonTitle.uppercased().setStyle(style: .buttonDark))
        totalLabel.attributedText = totalLabelTitle.uppercased().setStyle(style: .titleSmall)
        totalPriceLabel.attributedText = currencySign.setStyle(style: .priceTotal)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeButton()
        arrangeTotalLabel()
        arrangeTotalPriceLabel()
        arrangeLineImage()
        setViewHeight()
    }
    
    private func arrangeButton() {
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
    private func arrangeTotalLabel() {
        self.addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.firstBaseline.equalTo(button.snp.top).offset(-29)
        }
    }
    
    private func arrangeTotalPriceLabel() {
        self.addSubview(totalPriceLabel)
        totalPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.firstBaseline.equalTo(button.snp.top).offset(-29)
        }
    }
    
    private func arrangeLineImage() {
        self.addSubview(lineImage)
        lineImage.snp.makeConstraints { make in
            make.bottom.equalTo(totalLabel.snp.top).offset(-15)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    private func setViewHeight() {
        self.snp.makeConstraints { make in
            make.top.equalTo(lineImage)
        }
    }
    
    public func setTotalPrice(price: Decimal) {
        totalPriceLabel.text = "\(currencySign)\(price)"
    }

}
