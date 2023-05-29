//
//  CartItemCellView.swift
//  FashionStore
//
//  Created by Vyacheslav on 29.05.2023.
//

import Foundation
import UIKit

class CartItemCellView: UIView {
    
    // init properties
    private let imageName: String?
    private let loadImageAction: (String) async throws -> UIImage
    private let itemBrandLabelTitle: String
    private let itemNameColorSizeLabelTitle: String
    private let itemId: UUID
    private let minusButtonAction: (UUID) async throws -> Int
    private var count: Int
    private let plusButtonAction: (UUID) async throws -> Int
    private let itemPrice: Decimal
    
    private let itemImageView = UIImageView.makeImageView(
        contentMode: .scaleAspectFill,
        cornerRadius: 6.0
    )
    private let infoView = UIView(frame: .zero)
    private let spacerBrandModelHorizontalStack = UIStackView.makeHorizontalStackView(alignment: .top)
    private let spacerView = UIView(frame: .zero)
    private let brandModelVerticalStack = UIStackView.makeVerticalStackView()
    private let itemBrandLabel = UILabel.makeLabel(numberOfLines: 1)
    private let itemModelColorSizeLabel = UILabel.makeLabel(numberOfLines: 2)
    private let minusPlusCountHorizontalStack = UIStackView.makeHorizontalStackView(spacing: 2.0)
    private let minusButton = UIButton.makeIconicButton(imageName: ImageName.minusCircled)
    private let itemCountLabel = UILabel.makeLabel(numberOfLines: 1)
    private let plusButton = UIButton.makeIconicButton(imageName: ImageName.plusCircled)
    private let itemPriceLabel = UILabel.makeLabel(numberOfLines: 1)
    
    internal init(
        imageName: String? = nil,
        loadImageAction: @escaping (String) async throws -> UIImage,
        itemBrand: String,
        itemNameColorSize: String,
        itemId: UUID,
        minusButtonAction: @escaping (UUID) async throws -> Int,
        count: Int,
        plusButtonAction: @escaping (UUID) async throws -> Int,
        itemPrice: Decimal,
        frame: CGRect = .zero
    ) {
        self.imageName = imageName
        self.loadImageAction = loadImageAction
        self.itemBrandLabelTitle = itemBrand
        self.itemNameColorSizeLabelTitle = itemNameColorSize
        self.itemId = itemId
        self.minusButtonAction = minusButtonAction
        self.count = count
        self.plusButtonAction = plusButtonAction
        self.itemPrice = itemPrice
        super.init(frame: frame)
        
        // load image
        loadImage()
        
        // setup button actions
        setButtonActions()

        // setup typography texts
        setupUiTexts()
        
        // arrange elements
        arrangeUiElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // load image
    private func loadImage() {
        Task<Void, Never> {
            do {
                guard let imageName else { return }
                itemImageView.image = try await loadImageAction(imageName)
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    // adding button actions, that will change item count
    private func setButtonActions() {
        minusButton.addAction(UIAction { [weak self] _ in
            Task<Void, Never> {
                guard let self else { return }
                do {
                    // call action and set new count
                    self.count = try await self.minusButtonAction(self.itemId)
                    // assign new count to label
                    self.itemCountLabel.attributedText = String(self.count).setStyle(style: .bodyMediumDark)
                } catch {
                    Errors.handler.checkError(error)
                }
            }
        }, for: .primaryActionTriggered)
        
        plusButton.addAction(UIAction { [weak self] _ in
            Task<Void, Never> {
                guard let self else { return }
                do {
                    // call action and set new count
                    self.count = try await self.plusButtonAction(self.itemId)
                    // assign new count to label
                    self.itemCountLabel.attributedText = String(self.count).setStyle(style: .bodyMediumDark)
                } catch {
                    Errors.handler.checkError(error)
                }
            }
        }, for: .primaryActionTriggered)
    }

    private func setupUiTexts() {
        itemBrandLabel.attributedText = itemBrandLabelTitle.setStyle(style: .titleSmallHight)
        itemModelColorSizeLabel.attributedText = itemNameColorSizeLabelTitle.setStyle(style: .bodySmallLabelHight)
        itemCountLabel.attributedText = String(count).setStyle(style: .numberMediumDark)
        let itemPriceString = "$" + itemPrice.formatted(.number.precision(.fractionLength(0...2)))
        itemPriceLabel.attributedText = itemPriceString.setStyle(style: .priceMedium)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        
        // image
        self.addSubview(itemImageView)
        itemImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(itemImageView.snp.width).multipliedBy(4.0 / 3.0)
        }
        
        // right info section
        self.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.leading.equalTo(itemImageView.snp.trailing)
            make.top.trailing.equalToSuperview()
        }
        
        // brand and model stack with minimum size by spacer
        infoView.addSubview(spacerBrandModelHorizontalStack)
        spacerBrandModelHorizontalStack.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(4.0)
            make.leading.equalToSuperview().inset(2.0)
        }
        
        // minimus size spacer
        spacerBrandModelHorizontalStack.addArrangedSubview(spacerView)
        spacerView.snp.makeConstraints { make in
            make.width.equalTo(10.0)
            make.height.greaterThanOrEqualTo(61.0)
        }
        
        // brand and model labels stack
        spacerBrandModelHorizontalStack.addArrangedSubview(brandModelVerticalStack)
        
        // brand and model labels
        brandModelVerticalStack.addArrangedSubview(itemBrandLabel)
        brandModelVerticalStack.addArrangedSubview(itemModelColorSizeLabel)
        
        // plus/minus buttons and count label stack
        infoView.addSubview(minusPlusCountHorizontalStack)
        minusPlusCountHorizontalStack.snp.makeConstraints { make in
            make.top.equalTo(spacerBrandModelHorizontalStack.snp.bottom)
            make.leading.equalToSuperview().inset(2.0)
        }
        
        // plus/minus buttons and count label
        minusPlusCountHorizontalStack.addArrangedSubview(minusButton)
        minusPlusCountHorizontalStack.addArrangedSubview(itemCountLabel)
        minusPlusCountHorizontalStack.addArrangedSubview(plusButton)
        
        // price label
        infoView.addSubview(itemPriceLabel)
        itemPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(minusPlusCountHorizontalStack.snp.bottom)
            make.leading.equalToSuperview().inset(12.0)
            make.trailing.lessThanOrEqualToSuperview().inset(4.0)
            make.bottom.equalToSuperview().inset(2.0)
        }
    }
    
}

