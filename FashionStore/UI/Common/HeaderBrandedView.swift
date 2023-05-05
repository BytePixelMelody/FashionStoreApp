//
//  HeaderBrandedView.swift
//  FashionStore
//
//  Created by Vyacheslav on 13.04.2023.
//

import UIKit

class HeaderBrandedView: UIView {
    
    // buttons
    private let leftFirstButtonAction: (() -> Void)?
    private let rightFirstButtonAction: (() -> Void)?
    private let rightSecondButtonAction: (() -> Void)?
    
    private let leftFirstButtonImageName: String?
    private let rightFirstButtonImageName: String?
    private let rightSecondButtonImageName: String?
    
    private lazy var leftFirstButton = UIButton.makeIconicButton(imageName: leftFirstButtonImageName, action: leftFirstButtonAction)
    private lazy var rightFirstButton = UIButton.makeIconicButton(imageName: rightFirstButtonImageName, action: rightFirstButtonAction)
    private lazy var rightSecondButton = UIButton.makeIconicButton(imageName: rightSecondButtonImageName, action: rightSecondButtonAction)
    
    // logo image
    private let logoImage = UIImageView(image: UIImage(named: ImageName.logo))

    init(
        leftFirstButtonAction: (() -> Void)? = nil,
        leftFirstButtonImageName: String? = nil,
        
        rightFirstButtonAction: (() -> Void)? = nil,
        rightFirstButtonImageName: String? = nil,
        
        rightSecondButtonAction: (() -> Void)? = nil,
        rightSecondButtonImageName: String? = nil,
        
        frame: CGRect = .zero
    ) {
        self.leftFirstButtonAction = leftFirstButtonAction
        self.leftFirstButtonImageName = leftFirstButtonImageName
        
        self.rightFirstButtonAction = rightFirstButtonAction
        self.rightFirstButtonImageName = rightFirstButtonImageName
        
        self.rightSecondButtonAction = rightSecondButtonAction
        self.rightSecondButtonImageName = rightSecondButtonImageName
        
        super.init(frame: frame)
        
        arrangeUiElements()
    }
    
    // view doesn't support storyboards
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func arrangeUiElements() {
        arrangeLeftFirstButton()
        arrangeRightFirstButton()
        arrangeRightSecondButton()
        arrangeLogoImage()
        setViewHeight()
    }
    
    private func arrangeLeftFirstButton() {
        // no action - no button
        guard leftFirstButtonAction != nil else { return }
        
        self.addSubview(leftFirstButton)
        leftFirstButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().inset(6)
            make.size.equalTo(44)
        }
    }
    
    private func arrangeRightFirstButton() {
        // no action - no button
        guard rightFirstButtonAction != nil else { return }
        
        self.addSubview(rightFirstButton)
        rightFirstButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(8)
            make.size.equalTo(40)
        }
    }
    
    private func arrangeRightSecondButton() {
        // no action - no button
        guard rightSecondButtonAction != nil else { return }
        
        self.addSubview(rightSecondButton)
        rightSecondButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(48)
            make.size.equalTo(40)
        }
    }
    
    private func arrangeLogoImage() {
        self.addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setViewHeight() {
        self.snp.makeConstraints { make in
            make.bottom.equalTo(logoImage).offset(10)
        }
    }

}
