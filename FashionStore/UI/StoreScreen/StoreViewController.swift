//
//  StartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

// Interesting implementations:
// 1. Font styles with dynamic scaling
// 2. Keychain service with iCloud support
// 3. Router with custom routing and custom animations

// Interesting but not implemented:
// 1. Custom UINavigationBar - using undocumented methods

// Backlog:
// TODO: Database write to CoreData after loading from backend
// TODO: Collection Views with one presenter on screen, which communicates with subviews via ViewController

import UIKit
import SnapKit

protocol StoreViewProtocol: AnyObject {
    
    // TODO: delete this
    func addMockCellView(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productId: UUID,
        imageName: String?
    )
        
}

class StoreViewController: UIViewController {
    private static let screenNameTitle = "Fashion\nStore"
    private static let toProductButtonTitle = "TO PRODUCT"
    
    private let presenter: StorePresenterProtocol
    
    private lazy var goCartAction: () -> Void = { [weak self] in
        self?.presenter.showCart()
    }
    
    private lazy var headerBrandedView = HeaderBrandedView(
        rightFirstButtonAction: goCartAction,
        rightFirstButtonImageName: ImageName.cart,
        frame: .zero
    )
    
    private let productsScrollView = UIScrollView.makeScrollView()

    private let screenNameLabel = UILabel.makeLabel(numberOfLines: 0)
    
    private lazy var goProductAction: () -> Void = { [weak self] in
        self?.presenter.showProduct(productId: UUID(uuidString: "383cc439-7b76-4089-9a32-90e8e37a0377") ?? UUID(), image: nil)
    }
    
    private lazy var productButton = UIButton.makeDarkButton(imageName: ImageName.tagDark, action: goProductAction)
    
    init(presenter: StorePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupUiTexts()
        arrangeUiElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task<Void, Never> {
            do {
                try await presenter.loadCatalog()
                presenter.showMockView()
            } catch {
                Errors.handler.checkError(error)
            }
        }
    }

    
    private func setupUiTexts() {
        screenNameLabel.attributedText = Self.screenNameTitle.uppercased().setStyle(style: .titleLargeAlignLeft)
        productButton.configuration?.attributedTitle = AttributedString(Self.toProductButtonTitle.setStyle(style: .buttonDark))
    }
    
    // accessibility settings was changed - scale fonts
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUiTexts()
    }

    private func arrangeUiElements() {
        arrangeHeaderBrandedView()
        arrangeProductsScrollView()
        arrangeScreenNameLabel()
        arrangeProductButton()
    }

    private func arrangeHeaderBrandedView() {
        view.addSubview(headerBrandedView)
        headerBrandedView.snp.makeConstraints { make in
            make.top.right.left.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func arrangeProductsScrollView() {
        view.addSubview(productsScrollView)
        productsScrollView.snp.makeConstraints { make in
            make.top.equalTo(headerBrandedView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        productsScrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(productsScrollView.frameLayoutGuide.snp.width)
        }
        // contentLayoutGuide must have top and bottom constraints
    }

    private func arrangeScreenNameLabel() {
        productsScrollView.addSubview(screenNameLabel)
        
        screenNameLabel.snp.makeConstraints { make in
            make.top.equalTo(productsScrollView.contentLayoutGuide.snp.top).offset(400)
            make.centerX.equalTo(productsScrollView.contentLayoutGuide)
        }
    }
    
    private func arrangeProductButton() {
        productsScrollView.addSubview(productButton)
        productButton.snp.makeConstraints { make in
            make.top.equalTo(screenNameLabel.snp.bottom).offset(24)
            make.centerX.equalTo(screenNameLabel)
            make.height.equalTo(50)
            make.width.equalTo(210)
            make.bottom.equalTo(productsScrollView.contentLayoutGuide.snp.bottom).inset(500)
        }
    }
    
}

extension StoreViewController: StoreViewProtocol {
    
    // TODO: delete this
    func addMockCellView(
        productBrandLabelTitle: String,
        productNameLabelTitle: String,
        productPriceLabelTitle: String,
        productId: UUID,
        imageName: String?
    ) {
        let cellTapAction: (UUID, UIImage?) -> Void = { [weak self] productId, image in
            self?.presenter.showProduct(productId: productId, image: image)
        }
        
        let loadImageAction: (String) async throws -> UIImage? = { [weak self] imageName in
            // load image by presenter
            return try await self?.presenter.loadImage(imageName: imageName)
        }
        
        let mockProductCellView = ProductCellView(
            productBrandLabelTitle: productBrandLabelTitle,
            productNameLabelTitle: productNameLabelTitle,
            productPriceLabelTitle: productPriceLabelTitle,
            productId: productId,
            cellTapAction: cellTapAction,
            imageName: imageName,
            loadImageAction: loadImageAction
        )
        
        productsScrollView.addSubview(mockProductCellView)
        mockProductCellView.snp.makeConstraints { make in
            make.top.left.equalTo(productsScrollView.contentLayoutGuide).offset(16)
            make.width.equalTo(productsScrollView.contentLayoutGuide).dividedBy(2.0).inset((16.0 + 12.0 / 2) / 2) // insets on each side so... /= 2
        }
    }
    
}
