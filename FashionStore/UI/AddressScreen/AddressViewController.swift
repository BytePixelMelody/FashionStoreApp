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
        label.attributedText = "Address\nView\nController".uppercased().setStyle(style: .titleLarge)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

extension AddressViewController: AddressViewProtocol {
    
}
