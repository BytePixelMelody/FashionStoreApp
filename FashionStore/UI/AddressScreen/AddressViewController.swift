//
//  AddressViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol AddressViewProtocol: AnyObject {
    
}

class AddressViewController: UIViewController {
    
    private let presenter: AddressPresenterProtocol
    
    init(presenter: AddressPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AddressViewController: AddressViewProtocol {
    
}
