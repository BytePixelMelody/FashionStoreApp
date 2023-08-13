//
//  FooterTotalPriceView.swift
//  FashionStore
//
//  Created by Vyacheslav on 24.03.2023.
//

import UIKit

final class FooterTotalPriceView: UIView {

    // line image
    private let lineImage = UIImageView(image: UIImage(named: ImageName.lineGray))

    // total label
    private let totalLabelTitle: String
    private let totalLabel = UILabel.makeLabel(numberOfLines: 2)

    // total price label
    private let currencySign: String
    private var totalPrice: String?
    private let totalPriceLabel = UILabel.makeLabel(numberOfLines: 2)

    // button
    private let buttonAction: () -> Void
    private let buttonTitle: String
    private lazy var button = UIButton.makeDarkButton(imageName: ImageName.cartDark, action: buttonAction)

    init(
        totalLabelTitle: String,
        currencySign: String,
        buttonAction: @escaping () -> Void,
        buttonTitle: String,
        frame: CGRect = .zero
    ) {
        self.totalLabelTitle = totalLabelTitle
        self.currencySign = currencySign
        self.buttonAction = buttonAction
        self.buttonTitle = buttonTitle
        super.init(frame: frame)

        setupUiTexts()
        arrangeLayout()
    }

    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUiTexts() {
        button.configuration?.attributedTitle = AttributedString(buttonTitle.uppercased().setStyle(style: .buttonDark))
        totalLabel.attributedText = totalLabelTitle.uppercased().setStyle(style: .titleSmall)
        // price
        if let totalPrice {
            totalPriceLabel.attributedText = totalPrice.setStyle(style: .priceTotal)
        } else {
            totalPriceLabel.attributedText = nil
        }
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setupUiTexts()
        }
    }

    private func arrangeLayout() {
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
            make.bottom.equalTo(totalLabel.snp.top).offset(-17)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    private func setViewHeight() {
        self.snp.makeConstraints { make in
            make.top.equalTo(lineImage)
        }
    }

    func setTotalPrice(price: Decimal?) {
        if let price {
            totalPrice = "\(currencySign)\(price)"
        } else {
            totalPrice = nil
        }
        setupUiTexts()
    }

}
