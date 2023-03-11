//
//  PaymentMethodViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol PaymentMethodViewProtocol: AnyObject {
    
}

class PaymentMethodViewController: UIViewController {
    
    private let presenter: PaymentMethodPresenterProtocol
    
    init(presenter: PaymentMethodPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PaymentMethodViewController: PaymentMethodViewProtocol {
    
}
