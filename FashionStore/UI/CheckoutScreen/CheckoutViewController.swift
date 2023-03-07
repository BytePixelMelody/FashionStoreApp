//
//  CheckoutViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol CheckoutViewProtocol: AnyObject {
    
}

class CheckoutViewController: UIViewController {

    private let presenter: CheckoutPresenterProtocol
    
    init(presenter: CheckoutPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        setupLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupLabel() {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.attributedText = "Checkout\nView\nController".uppercased().setStyle(style: .titleLarge)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

extension CheckoutViewController: CheckoutViewProtocol {
    
}
