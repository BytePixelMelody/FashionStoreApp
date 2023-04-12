//
//  HeaderNamedView.swift
//  FashionStore
//
//  Created by Vyacheslav on 23.03.2023.
//

import UIKit

class HeaderNamedView: UIView {
        
    // buttons: close and back
    private let closeScreenHandler: (() -> Void)?
    private let backScreenHandler: (() -> Void)?
    private lazy var closeButton = UIButton.makeIconicButton(imageName: ImageName.close, handler: closeScreenHandler)
    private lazy var backButton = UIButton.makeIconicButton(imageName: ImageName.back, handler: backScreenHandler)
    
    // header label
    private let headerTitle: String
    private let headerLabel = UILabel.makeLabel(numberOfLines: 2)
    
    // header image
    private let spacerImage = UIImageView(image: UIImage(named: ImageName.spacer))

    init(
        closeScreenHandler: (() -> Void)? = nil,
        backScreenHandler: (() -> Void)? = nil,
        headerTitle: String,
        frame: CGRect = .zero
    ) {
        self.closeScreenHandler = closeScreenHandler
        self.backScreenHandler = backScreenHandler
        self.headerTitle = headerTitle
        super.init(frame: frame)
        
        setupUiTexts()
        arrangeUiElements()
    }
    
    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUiTexts() {
        headerLabel.attributedText = headerTitle.uppercased().setStyle(style: .titleLargeAlignCenter)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func arrangeUiElements() {
        arrangeCloseButton()
        arrangeBackButton()
        arrangeHeaderLabel()
        arrangeSpacerImage()
        setViewHeight()
    }
    
    private func arrangeCloseButton() {
        // no action - no button
        guard closeScreenHandler != nil else { return }
        
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeBackButton() {
        // no action - no button
        guard backScreenHandler != nil else { return }
        
        self.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().inset(6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeHeaderLabel() {
        self.addSubview(headerLabel)
        self.sendSubviewToBack(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(46)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    private func arrangeSpacerImage() {
        self.addSubview(spacerImage)
        spacerImage.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setViewHeight() {
        self.snp.makeConstraints { make in
            make.bottom.equalTo(spacerImage)
        }
    }

}
