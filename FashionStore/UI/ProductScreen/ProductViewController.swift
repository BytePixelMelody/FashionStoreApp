//
//  ProductViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol ProductViewProtocol: AnyObject {
    
    // fill view with info
    func fillProduct(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productDescriptionLabelTitle: String,
        image: UIImage?
    )
        
    // fill first (face) image
    func fillFaceImage(image: UIImage) async
    
    // enable button in product is not in cart
    func enableAddToCartButton() async
        
    // disable button if product is in cart
    func disableAddToCartButton() async
}

class ProductViewController: UIViewController {
    
    private var addToCartTitle = "Add to cart"
    private var inTheCartTitle = "In the cart"
    private lazy var addToCartButtonTitle = addToCartTitle
    
    private var productBrandLabelTitle: String?
    private var productNameLabelTitle: String?
    private var productPriceLabelTitle: String?
    private let descriptionLabelTitle = "Description"
    private var productDescriptionLabelTitle: String?
    
    private let presenter: ProductPresenterProtocol

    private lazy var goBackAction: () -> Void = { [weak presenter] in
        presenter?.backScreen()
    }

    private lazy var goCartAction: () -> Void = { [weak presenter] in
        presenter?.showCart()
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

    private let productImageView = UIImageView.makeImageView(
        contentMode: .scaleAspectFill,
        cornerRadius: 6.0,
        clipsToBounds: true
    )
    private let productBrandLabel = UILabel.makeLabel(numberOfLines: 0)
    private let productNameLabel = UILabel.makeLabel(numberOfLines: 0)
    private let productPriceLabel = UILabel.makeLabel(numberOfLines: 0)
    private let descriptionLabel = UILabel.makeLabel(numberOfLines: 0)
    private let productDescriptionLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var addToCartAction: () -> Void = { [weak presenter] in
        Task<Void, Never> { [weak presenter] in
            do {
                try await presenter?.addProductToCart()
                try await presenter?.checkInCartPresence()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    private lazy var addToCartButton = UIButton.makeDarkButton(imageName: ImageName.plusDark, action: addToCartAction)
    
    // storing task, cancelling is in willDisappearHandler()
    private lazy var checkAndLoadFaceImageTask: Task<Void, Never> = Task { [weak presenter] in
        do {
            try Task.checkCancellation()
            try await presenter?.checkAndLoadFaceImage()
        } catch {
            Errors.handler.checkError(error)
        }
    }
    
    // check item in cart, creating and calling in viewWillAppear, cancelation is in viewWillDisappear
    private var checkInCartPresenceTask: Task<Void, Never>?

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
        
        // one-time task call in the lifecycle of the view controller
        _ = checkAndLoadFaceImageTask
        
        setupUiTexts()
        fillProductStackView()
        arrangeLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // creating and calling task, cancelation is in viewWillDisappear
        checkInCartPresenceTask = Task { [weak presenter] in
            do {
                try Task.checkCancellation()
                try await presenter?.checkInCartPresence()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        checkAndLoadFaceImageTask.cancel()
        checkInCartPresenceTask?.cancel()
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
        addToCartButton.configuration?.attributedTitle = AttributedString(addToCartButtonTitle.uppercased().setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            setupUiTexts()
        }
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

    private func arrangeLayout() {
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
            make.top.equalTo(productScrollView.contentLayoutGuide).offset(12)
            make.bottom.equalTo(productScrollView.contentLayoutGuide).offset(-20)
            make.left.right.equalTo(productScrollView.contentLayoutGuide).inset(16)
        }
    }
    
    private func arrangeProductImageView() {
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
    
    // enable button in product is not in cart
    func enableAddToCartButton() async {
        addToCartButton.isEnabled = true
        var config = addToCartButton.configuration
        config?.background.backgroundColor = UIColor(named: "Active") ?? .black
        config?.image = UIImage(named: ImageName.plusDark)
        addToCartButtonTitle = addToCartTitle
        config?.attributedTitle = AttributedString(addToCartButtonTitle.uppercased().setStyle(style: .buttonDark))
        addToCartButton.configuration = config
    }
    
    // disable button if product is in cart
    func disableAddToCartButton() async {
        addToCartButton.isEnabled = false
        var config = addToCartButton.configuration
        config?.background.backgroundColor = UIColor(named: "ButtonDisabled") ?? .lightGray
        config?.image = nil
        addToCartButtonTitle = inTheCartTitle
        config?.attributedTitle = AttributedString(addToCartButtonTitle.uppercased().setStyle(style: .buttonDark))
        addToCartButton.configuration = config
    }
    
}
