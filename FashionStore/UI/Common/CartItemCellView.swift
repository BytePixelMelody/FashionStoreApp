//
//  CartItemCellView.swift
//  FashionStore
//
//  Created by Vyacheslav on 29.05.2023.
//

import Foundation
import UIKit

final class CartItemCellView: UICollectionViewCell {

    // setup properties
    private var imageName: String?
    private var itemBrandLabelTitle: String?
    private var itemNameColorSizeLabelTitle: String?
    private var itemID: UUID?
    private var minusButtonAction: ((UUID, Int) async throws -> Void)?
    private var count: Int?
    private var plusButtonAction: ((UUID, Int) async throws -> Void)?
    private var itemPrice: Decimal?

    // price calculation
    private var itemTotalPrice: Decimal? {
        guard let count, let itemPrice else { return nil }
        return Decimal(count) * itemPrice
    }

    // UI elements
    private let itemImageView = UIImageView.makeImageView(
        contentMode: .scaleAspectFill,
        cornerRadius: 4.0,
        clipsToBounds: true
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
    private let itemTotalPriceLabel = UILabel.makeLabel(numberOfLines: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)

        // arrange elements
        arrangeLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // arrange elements
        arrangeLayout()
    }

    // setup properties and actions
    public func setup(
        imageName: String?,
        loadImageAction: @escaping (String) async throws -> UIImage?,
        itemBrand: String,
        itemNameColorSize: String,
        itemID: UUID,
        minusButtonAction: @escaping (UUID, Int) async throws -> Void,
        count: Int,
        plusButtonAction: @escaping (UUID, Int) async throws -> Void,
        itemPrice: Decimal
    ) {
        // if cell not prepared for reuse
        guard self.itemID == nil else {
            // update only count
            self.count = count
            // setup typography texts of updated count and price
            setupUiTexts()
            return
        }

        // setup properties
        self.imageName = imageName
        self.itemBrandLabelTitle = itemBrand
        self.itemNameColorSizeLabelTitle = itemNameColorSize
        self.itemID = itemID
        self.minusButtonAction = minusButtonAction
        self.count = count
        self.plusButtonAction = plusButtonAction
        self.itemPrice = itemPrice

        // image loading
        loadImage(loadImageAction: loadImageAction)

        // setup button actions
        setButtonActions()

        // setup typography texts
        setupUiTexts()
    }

    // load image
    private func loadImage(loadImageAction: @escaping (String) async throws -> UIImage?) {
        Task<Void, Never> {
            do {
                guard let imageName else { return }

                let image = try await loadImageAction(imageName)

                // cell image name check after loading
                if imageName == self.imageName {
                    itemImageView.image = image
                }
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }

    // adding button actions, that will change item count
    private func setButtonActions() {
        minusButton.addAction(UIAction { [weak self] _ in
            Task<Void, Never> { [weak self] in
                guard let self, let minusButtonAction, let itemID, let count else { return }
                do {
                    // call action and set new count
                    try await minusButtonAction(itemID, count - 1)
                } catch {
                    Errors.handler.checkError(error)
                }
            }
        }, for: .primaryActionTriggered)

        plusButton.addAction(UIAction { [weak self] _ in
            Task<Void, Never> { [weak self] in
                guard let self, let plusButtonAction, let itemID, let count else { return }
                do {
                    // call action and set new count
                    try await plusButtonAction(itemID, count + 1)
                } catch {
                    Errors.handler.checkError(error)
                }
            }
        }, for: .primaryActionTriggered)
    }

    private func setupUiTexts() {
        itemBrandLabel.attributedText = itemBrandLabelTitle?.setStyle(style: .titleSmallHight)
        itemModelColorSizeLabel.attributedText = itemNameColorSizeLabelTitle?.setStyle(style: .bodySmallLabelHight)
        if let count {
            itemCountLabel.attributedText = String(count).setStyle(style: .numberMediumDark)
        }
        if let itemTotalPrice {
            let itemTotalPriceString = "$" + itemTotalPrice.formatted(.number.precision(.fractionLength(0...2)))
            itemTotalPriceLabel.attributedText = itemTotalPriceString.setStyle(style: .priceMedium)
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

        // image
        contentView.addSubview(itemImageView)
        itemImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(itemImageView.snp.width).multipliedBy(4.0 / 3.0).priority(.high)
            make.height.lessThanOrEqualToSuperview()
        }

        // right info section
        contentView.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.leading.equalTo(itemImageView.snp.trailing)
            make.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.medium)
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
        infoView.addSubview(itemTotalPriceLabel)
        itemTotalPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(minusPlusCountHorizontalStack.snp.bottom)
            make.leading.equalToSuperview().inset(12.0)
            make.trailing.lessThanOrEqualToSuperview().inset(4.0)
            make.bottom.equalToSuperview().inset(2.0)
        }

        // buttons to front
        contentView.bringSubviewToFront(minusButton)
        contentView.bringSubviewToFront(plusButton)
    }

    // clean cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        // clean info
        imageName = nil
        itemBrandLabelTitle = nil
        itemNameColorSizeLabelTitle = nil
        itemID = nil
        minusButtonAction = nil
        count = nil
        plusButtonAction = nil
        itemPrice = nil

        // clean image
        itemImageView.image = nil

        // clean button actions
        minusButton.removeTarget(nil, action: nil, for: .allEvents)
        plusButton.removeTarget(nil, action: nil, for: .allEvents)

        // clean texts
        itemBrandLabel.attributedText = nil
        itemModelColorSizeLabel.attributedText = nil
        itemCountLabel.attributedText = nil
        itemTotalPriceLabel.attributedText = nil
    }

    // automatic cell size calculation for collection view
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let collectionViewWidth: CGFloat
        if let superviewCollectionViewWidth = superview?.frame.width {
            collectionViewWidth = superviewCollectionViewWidth
        } else {
            collectionViewWidth = UIScreen.main.bounds.width
        }
        let leftRightInsetsWidth = CartItemsFlowLayoutConstants.sectionInset.left + CartItemsFlowLayoutConstants.sectionInset.right
        let allInteritemSpacings = CartItemsFlowLayoutConstants.minimumInteritemSpacing * (CartItemsFlowLayoutConstants.cellsInLineCount - 1)
        let itemWidth = ((collectionViewWidth - leftRightInsetsWidth - allInteritemSpacings) / CartItemsFlowLayoutConstants.cellsInLineCount)
            .rounded(.down)

        let targetSize = CGSize(width: itemWidth, height: .zero)
        let size = self.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        layoutAttributes.size = size

        return layoutAttributes
    }

}
