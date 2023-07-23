//
//  ProductCellView.swift
//  FashionStore
//
//  Created by Vyacheslav on 27.05.2023.
//

import Foundation
import UIKit

final class ProductCellView: UICollectionViewCell {
    
    // setup properties
    private var imageName: String?
    private var productBrandLabelTitle: String?
    private var productNameLabelTitle: String?
    private var productPriceLabelTitle: String?
    private var productID: UUID?
    private var cellTapAction: ((UUID, UIImage?) -> Void)?
   
    private let commonVerticalStackView = UIStackView.makeVerticalStackView()
    private let labelsContainerView = UIView(frame: .zero)
    private let labelsVerticalStackView = UIStackView.makeVerticalStackView()
    
    private let productImageView = UIImageView.makeImageView(
        contentMode: .scaleAspectFill,
        cornerRadius: 4.0,
        clipsToBounds: true
    )
    private let productBrandLabel = UILabel.makeLabel(numberOfLines: 1)
    private let productNameLabel = UILabel.makeLabel(numberOfLines: 2)
    private let productPriceLabel = UILabel.makeLabel(numberOfLines: 1)
    
    private lazy var cellTap = UITapGestureRecognizer(target: self, action: #selector(cellSelector))
    
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
    
    public func setup(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productID: UUID,
        cellTapAction: @escaping (UUID, UIImage?) -> Void,
        imageName: String?,
        loadImageAction: @escaping (String) async throws -> UIImage?
    ) {
        self.productBrandLabelTitle = productBrandLabelTitle
        self.productNameLabelTitle = productNameLabelTitle
        self.productPriceLabelTitle = productPriceLabelTitle
        self.productID = productID
        self.cellTapAction = cellTapAction
        self.imageName = imageName
        
        // load image
        loadImage(loadImageAction: loadImageAction)
        
        // adding tap
        self.addGestureRecognizer(cellTap)

        // setup typography texts
        setupUiTexts()
    }
    
    private func loadImage(loadImageAction: @escaping (String) async throws -> UIImage?) {
        Task<Void, Never> {
            do {
                guard let imageName else { return }
                productImageView.image = try await loadImageAction(imageName)
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    // called by tap on the view
    @objc
    private func cellSelector() {
        guard let cellTapAction, let productID else { return }
        cellTapAction(productID, productImageView.image)
    }
    
    private func setupUiTexts() {
        productBrandLabel.attributedText = productBrandLabelTitle?.setStyle(style: .bodySmallActive)
        productNameLabel.attributedText = productNameLabelTitle?.setStyle(style: .bodySmallLabel)
        productPriceLabel.attributedText = productPriceLabelTitle?.setStyle(style: .priceMedium)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setupUiTexts()
        }
    }
    
    private func arrangeLayout() {
        contentView.addSubview(commonVerticalStackView)
        commonVerticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        commonVerticalStackView.addArrangedSubview(productImageView)
        
        productImageView.snp.makeConstraints { make in
            make.height.equalTo(productImageView.snp.width).multipliedBy(4.0 / 3.0).priority(.high)
        }

        commonVerticalStackView.setCustomSpacing(9.0, after: productImageView)
        commonVerticalStackView.addArrangedSubview(labelsContainerView)
        
        labelsContainerView.addSubview(labelsVerticalStackView)
        labelsVerticalStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(4.0)
        }
        
        labelsVerticalStackView.addArrangedSubview(productBrandLabel)
        labelsVerticalStackView.addArrangedSubview(productNameLabel)
        labelsVerticalStackView.addArrangedSubview(productPriceLabel)
    }
    
    // clean cell for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // clean info
        productBrandLabelTitle = nil
        productNameLabelTitle = nil
        productPriceLabelTitle = nil
        productID = nil
        cellTapAction = nil
        imageName = nil
        
        // clean image
        productImageView.image = nil
        
        // clean texts
        productBrandLabel.attributedText = nil
        productNameLabel.attributedText = nil
        productPriceLabel.attributedText = nil
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
        let leftRightInsetsWidth = ProductsFlowLayoutConstants.sectionInset.left + ProductsFlowLayoutConstants.sectionInset.right
        let allInteritemSpacings = ProductsFlowLayoutConstants.minimumInteritemSpacing * (ProductsFlowLayoutConstants.cellsInLineCount - 1)
        let itemWidth = ((collectionViewWidth - leftRightInsetsWidth - allInteritemSpacings) / ProductsFlowLayoutConstants.cellsInLineCount).rounded(.down)

        let targetSize = CGSize(width: itemWidth, height: .zero)
        let size = self.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        layoutAttributes.size = size
        
        return layoutAttributes
    }
    
}
