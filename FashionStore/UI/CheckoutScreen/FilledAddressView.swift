//
//  FilledAddressView.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.04.2023.
//

import UIKit

class FilledAddressView: UIView {
    
    // labels texts, from init
    private let firstLastNameLabelText: String
    private let addressLabelText: String
    private let cityStateZipLabelText: String
    private let phoneLabelText: String
    
    // action for tap on the view, from init
    private let editInfoAction: () -> Void
    
    // create labels
    private let firstLastNameLabel = UILabel.makeLabel(numberOfLines: 1)
    private let addressLabel = UILabel.makeLabel(numberOfLines: 1)
    private let cityStateZipLabel = UILabel.makeLabel(numberOfLines: 1)
    private let phoneLabel = UILabel.makeLabel(numberOfLines: 1)
    
    init(
        firstLastNameLabelText: String,
        addressLabelText: String,
        cityStateZipLabelText: String,
        phoneLabelText: String,
        editInfoAction: @escaping () -> Void,
        frame: CGRect = .zero
    ) {
        self.firstLastNameLabelText = firstLastNameLabelText
        self.addressLabelText = addressLabelText
        self.cityStateZipLabelText = cityStateZipLabelText
        self.phoneLabelText = phoneLabelText
        self.editInfoAction = editInfoAction
        super.init(frame: frame)

        // setup typography
        setupUiTexts()
        
        // arrange elements
        arrangeUiElements()
    }

    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUiTexts() {
        firstLastNameLabel.attributedText = firstLastNameLabelText.setStyle(style: .addressUserName)
        addressLabel.attributedText = addressLabelText.setStyle(style: .address)
        cityStateZipLabel.attributedText = cityStateZipLabelText.setStyle(style: .address)
        phoneLabel.attributedText = phoneLabelText.setStyle(style: .address)
    }

    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
//        arrangeInfoNameLabel()
//        arrangeAddInfoButton()
//        setViewHeight()
    }

//    private func arrangeInfoNameLabel() {
//        self.addSubview(infoNameLabel)
//        infoNameLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(25)
//            make.left.right.equalToSuperview().inset(16)
//        }
//    }
//
//    private func arrangeAddInfoButton() {
//        self.addSubview(addInfoButton)
//        addInfoButton.snp.makeConstraints { make in
//            make.top.equalTo(infoNameLabel.snp.bottom).offset(12)
//            make.left.right.equalToSuperview().inset(16)
//            make.height.equalTo(50)
//        }
//    }
//
//    private func setViewHeight() {
//        self.snp.makeConstraints { make in
//            make.bottom.equalTo(addInfoButton).offset(11)
//        }
//    }

}
