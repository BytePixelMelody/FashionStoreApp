//
//  StartViewController.swift
//  FashionStore
//
//  Created by Vyacheslav on 28.02.2023.
//

import UIKit
import SnapKit

protocol StoreViewProtocol: AnyObject {
    
}

class StoreViewController: UIViewController {

    private let presenter: StorePresenterProtocol
    
    private let label = UILabel(frame: .zero)
    private var toProductButton: UIButton?
    
    init(presenter: StorePresenterProtocol) {
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
        setupProductButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupLabel() {
        label.numberOfLines = 0
        label.attributedText = "Store\nView\nController".uppercased().setStyle(style: .titleLarge)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupProductButton() {
        toProductButton = UIButton.makeButtonDark(text: "To product".uppercased())
        guard let toProductButton else { return }
        view.addSubview(toProductButton)
        toProductButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(56)
        }
    }

    // accessibility font scale on the fly
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupLabel()
        setupProductButton()
    }
}

extension StoreViewController: StoreViewProtocol {
    
}
