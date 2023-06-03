//
//  ProductCellView.swift
//  FashionStore
//
//  Created by Vyacheslav on 27.05.2023.
//

import Foundation
import UIKit

class ProductCellView: UICollectionViewCell {
    
    // cell reuse identifier
    static var identifier: String {
        String(describing: self)
    }
    
    // setup properties
    private var imageName: String?
    private var productBrandLabelTitle: String?
    private var productNameLabelTitle: String?
    private var productPriceLabelTitle: String?
    private var productId: UUID?
    private var cellTapAction: ((UUID, UIImage?) -> Void)?
   
    private let commonVerticalStackView = UIStackView.makeVerticalStackView()
    private let labelsContainerView = UIView(frame: .zero)
    private let labelsVerticalStackView = UIStackView.makeVerticalStackView()
    
    private let productImageView = UIImageView.makeImageView(
        contentMode: .scaleAspectFill,
        cornerRadius: 6.0,
        clipsToBounds: true
    )
    private let productBrandLabel = UILabel.makeLabel(numberOfLines: 1)
    private let productNameLabel = UILabel.makeLabel(numberOfLines: 1)
    private let productPriceLabel = UILabel.makeLabel(numberOfLines: 1)
    
    private lazy var cellTap = UITapGestureRecognizer(target: self, action: #selector(cellSelector))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // arrange elements
        arrangeLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setup(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productId: UUID,
        cellTapAction: @escaping (UUID, UIImage?) -> Void,
        imageName: String?,
        loadImageAction: @escaping (String) async throws -> UIImage?
    ) {
        self.productBrandLabelTitle = productBrandLabelTitle
        self.productNameLabelTitle = productNameLabelTitle
        self.productPriceLabelTitle = productPriceLabelTitle
        self.productId = productId
        self.cellTapAction = cellTapAction
        self.imageName = imageName
        
        // load image
        Task<Void, Never> {
            do {
                guard let imageName else { return }
                productImageView.image = try await loadImageAction(imageName)
            } catch {
                Errors.handler.checkError(error)
            }
        }
        
        // adding tap
        self.addGestureRecognizer(cellTap)

        // setup typography texts
        setupUiTexts()
    }
    
    // called by tap on the view
    @objc
    private func cellSelector() {
        guard let cellTapAction, let productId else { return }
        cellTapAction(productId, productImageView.image)
    }
    
    private func setupUiTexts() {
        productBrandLabel.attributedText = productBrandLabelTitle?.setStyle(style: .bodySmallActive)
        productNameLabel.attributedText = productNameLabelTitle?.setStyle(style: .bodySmallLabel)
        productPriceLabel.attributedText = productPriceLabelTitle?.setStyle(style: .priceMedium)
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }
    
    private func arrangeLayout() {
        
        self.addSubview(commonVerticalStackView)
        commonVerticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        commonVerticalStackView.addArrangedSubview(productImageView)
        
        productImageView.snp.makeConstraints { make in
            make.height.equalTo(productImageView.snp.width).multipliedBy(4.0 / 3.0)
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
    
}
