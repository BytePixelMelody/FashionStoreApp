//
//  CartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol CartViewProtocol: AnyObject {
    
}

class CartViewController: UIViewController {
    private static let topButtonTitle = "CLOSE"
    private static let labelText = "Store\nView\nController"
    private static let bottomButtonTitle = "TO PRODUCT"
    
    private var topButton = UIButton.makeDarkButton()
    private var label = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    private var bottomButton = UIButton.makeDarkButton()

    private let presenter: CartPresenterProtocol
    
    init(presenter: CartPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
}

extension CartViewController: CartViewProtocol {
    
}
