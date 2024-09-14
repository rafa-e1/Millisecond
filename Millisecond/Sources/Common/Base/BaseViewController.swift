//
//  BaseViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/13/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSubviews()
        setConstraints()
    }

    func setupUI() { }

    func setupSubviews() { }

    func setConstraints() { }
}
