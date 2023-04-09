//
//  AddCheckoutDetailsView.swift
//  FashionStore
//
//  Created by Vyacheslav on 25.03.2023.
//

import UIKit

class AddCheckoutDetailsView: UIView {
    
    // label
    private let infoLabelText: String
    private let infoNameLabel = UILabel.makeLabel(numberOfLines: 0)
    // button
    private let addInfoButtonTitle: String
    private let addInfoAction: () -> Void
    private lazy var addInfoButton = UIButton.makeGrayCapsuleButton(imageName: ImageName.plus, handler: addInfoAction)
    
    init(
        infoLabelText: String,
        addInfoButtonTitle: String,
        addInfoAction: @escaping () -> Void,
        frame: CGRect = .zero
    ) {
        self.infoLabelText = infoLabelText
        self.addInfoButtonTitle = addInfoButtonTitle
        self.addInfoAction = addInfoAction
        super.init(frame: frame)
        
        setupUiTexts()
        arrangeUiElements()
    }
    
    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUiTexts() {
        infoNameLabel.attributedText = infoLabelText.uppercased().setStyle(style: .subHeader)
        addInfoButton.configuration?.attributedTitle = AttributedString(addInfoButtonTitle.setStyle(style: .bodyLarge))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func arrangeUiElements() {
        arrangeInfoNameLabel()
        arrangeAddInfoButton()
        setViewHeight()
    }

    private func arrangeInfoNameLabel() {
        self.addSubview(infoNameLabel)
        infoNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.right.equalToSuperview()
        }
    }
    
    private func arrangeAddInfoButton() {
        self.addSubview(addInfoButton)
        addInfoButton.snp.makeConstraints { make in
            make.top.equalTo(infoNameLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    private func setViewHeight() {
        self.snp.makeConstraints { make in
            make.bottom.equalTo(addInfoButton).offset(11)
        }
    }

}
