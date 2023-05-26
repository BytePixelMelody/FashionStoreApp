//
//  ProductViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol ProductViewProtocol: AnyObject {
    
    func fillProduct(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productDescriptionLabelTitle: String,
        image: UIImage?
    )
        
    func fillFaceImage(image: UIImage) async
    
}

class ProductViewController: UIViewController {
    
    private static let addToCartButtonTitle = "Add to cart"
    
    private let productImageView = UIImageView.makeImageView(
        contentMode: .scaleAspectFill,
        cornerRadius: 6.0
    )
    private var productBrandLabelTitle: String?
    private var productNameLabelTitle: String?
    private var productPriceLabelTitle: String?
    private let descriptionLabelTitle = "Description"
    private var productDescriptionLabelTitle: String?
    
    private let presenter: ProductPresenterProtocol

    private lazy var goBackAction: () -> Void = { [weak self] in
        self?.presenter.backScreen()
    }

    private lazy var goCartAction: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    
    private lazy var headerBrandedView = HeaderBrandedView(
        leftFirstButtonAction: goBackAction,
        leftFirstButtonImageName: ImageName.backLowered,
        rightFirstButtonAction: goCartAction,
        rightFirstButtonImageName: ImageName.cart,
        frame: .zero
    )

    private let productScrollView = UIScrollView.makeScrollView()

    // creating stack view
    private let productStackView = UIStackView.makeVerticalStackView(spacing: 8)

    private let productBrandLabel = UILabel.makeLabel(numberOfLines: 0)
    private let productNameLabel = UILabel.makeLabel(numberOfLines: 0)
    private let productPriceLabel = UILabel.makeLabel(numberOfLines: 0)
    private let descriptionLabel = UILabel.makeLabel(numberOfLines: 0)
    private let productDescriptionLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var addToCartAction: () -> Void = {
        Task<Void, Never> { [weak self] in
            do {
                try await self?.presenter.addProductToCart()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    private lazy var addToCartButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, action: addToCartAction)
    
    // storing task to cancel it on willDisappearHandler()
    private var checkAndLoadFaceImageTask: Task<Void, Never>?

    init(presenter: ProductPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        presenter.loadInfo()
        checkAndLoadFaceImageTask = Task { [weak self] in
            do {
                guard !Task.isCancelled else { return }
                try await self?.presenter.checkAndLoadFaceImage()
            } catch {
                Errors.handler.checkError(error)
            }
        }
        
        setupUiTexts()
        fillProductStackView()
        arrangeUiElements()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        checkAndLoadFaceImageTask?.cancel()
    }
    
    private func setupUiTexts() {
        if let productBrandLabelTitle,
            let productNameLabelTitle,
            let productPriceLabelTitle,
            let productDescriptionLabelTitle
        {
            productBrandLabel.attributedText = productBrandLabelTitle.uppercased().setStyle(style: .titleMedium)
            productNameLabel.attributedText = productNameLabelTitle.setStyle(style: .bodyLarge)
            productPriceLabel.attributedText = productPriceLabelTitle.setStyle(style: .priceLarge)
            descriptionLabel.attributedText = descriptionLabelTitle.uppercased().setStyle(style: .titleSmall)
            productDescriptionLabel.attributedText = productDescriptionLabelTitle.setStyle(style: .bodyMedium)
        }
        addToCartButton.configuration?.attributedTitle = AttributedString(Self.addToCartButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func fillProductStackView() {
        productStackView.addArrangedSubview(productImageView)
        productStackView.setCustomSpacing(29, after: productImageView)
        productStackView.addArrangedSubview(productBrandLabel)
        productStackView.addArrangedSubview(productNameLabel)
        productStackView.addArrangedSubview(productPriceLabel)
        productStackView.setCustomSpacing(25, after: productPriceLabel)
        productStackView.addArrangedSubview(descriptionLabel)
        productStackView.setCustomSpacing(5, after: descriptionLabel)
        productStackView.addArrangedSubview(productDescriptionLabel)
    }

    private func arrangeUiElements() {
        arrangeHeaderBrandedView()
        arrangeProductScrollView()
        arrangeProductStackView()
        arrangeProductImageView()
        arrangeAddToCartButton()
    }
    
    private func arrangeHeaderBrandedView() {
        view.addSubview(headerBrandedView)
        headerBrandedView.snp.makeConstraints { make in
            make.top.right.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeProductScrollView() {
        view.addSubview(productScrollView)
        productScrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBrandedView.snp.bottom)
            make.left.right.equalToSuperview()
            // bottom is in footer constraints
        }
        productScrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(productScrollView.frameLayoutGuide.snp.width)
        }
        // contentLayoutGuide must have top and bottom constraints
    }
    
    private func arrangeProductStackView() {
        productScrollView.addSubview(productStackView)
        productStackView.snp.makeConstraints { make in
            make.top.equalTo(productScrollView.contentLayoutGuide).offset(17)
            make.bottom.equalTo(productScrollView.contentLayoutGuide).offset(-20)
            make.left.right.equalTo(productScrollView.contentLayoutGuide).inset(16)
        }
    }
    
    private func arrangeProductImageView() {
        productImageView.clipsToBounds = true
        productImageView.snp.makeConstraints { make in
            make.height.equalTo(productImageView.snp.width).multipliedBy(4.0 / 3.0)
        }
    }

    private func arrangeAddToCartButton() {
        view.addSubview(addToCartButton)
        addToCartButton.snp.makeConstraints { make in
            make.top.equalTo(productScrollView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(34)
            make.height.equalTo(50)
        }
    }
    
}

extension ProductViewController: ProductViewProtocol {
    
    func fillProduct(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productDescriptionLabelTitle: String,
        image: UIImage?
    ) {
        self.productBrandLabelTitle = productBrandLabelTitle
        self.productNameLabelTitle = productNameLabelTitle
        self.productPriceLabelTitle = productPriceLabelTitle
        self.productDescriptionLabelTitle = productDescriptionLabelTitle
        self.productImageView.image = image
    }
    
    func fillFaceImage(image: UIImage) async {
        self.productImageView.image = image
    }

}
