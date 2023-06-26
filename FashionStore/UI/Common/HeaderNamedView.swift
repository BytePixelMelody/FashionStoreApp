//
//  HeaderNamedView.swift
//  FashionStore
//
//  Created by Vyacheslav on 23.03.2023.
//

import UIKit

final class HeaderNamedView: UIView {
        
    // buttons: close and back
    private let closeScreenAction: (() -> Void)?
    private let backScreenAction: (() -> Void)?
    private lazy var closeButton = UIButton.makeIconicButton(imageName: ImageName.close, action: closeScreenAction)
    private lazy var backButton = UIButton.makeIconicButton(imageName: ImageName.back, action: backScreenAction)
    
    // header label
    private let headerTitle: String
    private let headerLabel = UILabel.makeLabel(numberOfLines: 2)
    
    // header image
    private let spacerImage = UIImageView(image: UIImage(named: ImageName.spacer))

    init(
        closeScreenAction: (() -> Void)? = nil,
        backScreenAction: (() -> Void)? = nil,
        headerTitle: String,
        frame: CGRect = .zero
    ) {
        self.closeScreenAction = closeScreenAction
        self.backScreenAction = backScreenAction
        self.headerTitle = headerTitle
        super.init(frame: frame)
        
        setupUiTexts()
        arrangeLayout()
    }
    
    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUiTexts() {
        headerLabel.attributedText = headerTitle.uppercased().setStyle(style: .titleLargeAlignCentered)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setupUiTexts()
        }
    }
    
    private func arrangeLayout() {
        arrangeCloseButton()
        arrangeBackButton()
        arrangeHeaderLabel()
        arrangeSpacerImage()
        setViewHeight()
    }
    
    private func arrangeCloseButton() {
        // no action - no button
        guard closeScreenAction != nil else { return }
        
        self.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeBackButton() {
        // no action - no button
        guard backScreenAction != nil else { return }
        
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
            make.top.equalToSuperview().offset(54)
            make.left.right.equalToSuperview().inset(16)
        }
    }

    private func arrangeSpacerImage() {
        self.addSubview(spacerImage)
        spacerImage.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(11)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setViewHeight() {
        self.snp.makeConstraints { make in
            make.bottom.equalTo(spacerImage)
        }
    }

}
