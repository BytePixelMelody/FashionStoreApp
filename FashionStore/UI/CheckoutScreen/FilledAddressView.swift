//
//  FilledAddressView.swift
//  FashionStore
//
//  Created by Vyacheslav on 07.04.2023.
//

import UIKit

class FilledAddressView: UIView {
    
    // labels texts, action from init
    private let firstLastNameLabelText: String
    private let addressLabelText: String
    private let cityStateZipLabelText: String
    private let countryLabelText: String
    private let phoneLabelText: String
    private let editInfoAction: () -> Void
    private let deleteInfoAction: () -> Void
    
    private lazy var editInfoTap = UITapGestureRecognizer(target: self, action: #selector(editInfoSelector))
    private lazy var deleteInfoButton = UIButton.makeIconicButton(imageName: ImageName.trash, action: deleteInfoAction)

    // creating stack views
    private let horizontalStackView = UIStackView.makeHorizontalStackView(spacing: 12, alignment: .center)
    private let verticalStackView = UIStackView.makeVerticalStackView()
    
    // creating labels
    private let firstLastNameLabel = UILabel.makeLabel(numberOfLines: 0)
    private let addressLabel = UILabel.makeLabel(numberOfLines: 0)
    private let cityStateZipLabel = UILabel.makeLabel(numberOfLines: 0)
    private let countryLabel = UILabel.makeLabel(numberOfLines: 0)
    private let phoneLabel = UILabel.makeLabel(numberOfLines: 0)
    
    // creating a line image
    private let lineImage = UIImageView(image: UIImage(named: ImageName.lineGray))
    
    init(
        firstLastNameLabelText: String,
        addressLabelText: String,
        cityStateZipLabelText: String,
        countryLabelText: String,
        phoneLabelText: String,
        editInfoAction: @escaping () -> Void,
        deleteInfoAction: @escaping () -> Void,
        frame: CGRect = .zero
    ) {
        self.firstLastNameLabelText = firstLastNameLabelText
        self.addressLabelText = addressLabelText
        self.cityStateZipLabelText = cityStateZipLabelText
        self.countryLabelText = countryLabelText
        self.phoneLabelText = phoneLabelText
        self.editInfoAction = editInfoAction
        self.deleteInfoAction = deleteInfoAction
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
        firstLastNameLabel.attributedText = firstLastNameLabelText.setStyle(style: .infoLarge)
        addressLabel.attributedText = addressLabelText.setStyle(style: .address)
        cityStateZipLabel.attributedText = cityStateZipLabelText.setStyle(style: .address)
        countryLabel.attributedText = countryLabelText.setStyle(style: .address)
        phoneLabel.attributedText = phoneLabelText.setStyle(style: .address)
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
            make.right.equalToSuperview().inset(8)
        }
        
        // adding vertical stack view for labels to horizontal stack view
        horizontalStackView.addArrangedSubview(verticalStackView)
        
        // adding labels to vertical stack view
        verticalStackView.addArrangedSubview(firstLastNameLabel)
        verticalStackView.setCustomSpacing(3, after: firstLastNameLabel)
        verticalStackView.addArrangedSubview(addressLabel)
        verticalStackView.addArrangedSubview(cityStateZipLabel)
        verticalStackView.addArrangedSubview(countryLabel)
        verticalStackView.setCustomSpacing(3, after: countryLabel)
        verticalStackView.addArrangedSubview(phoneLabel)

        // adding forward image to horizontal stack view
        horizontalStackView.addArrangedSubview(deleteInfoButton)
        
        deleteInfoButton.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        
        // adding bottom line to view
        self.addSubview(lineImage)
        lineImage.snp.makeConstraints { make in
            make.top.equalTo(horizontalStackView.snp.bottom).offset(22)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

}
