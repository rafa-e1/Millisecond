//
//  LoginViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/30/24.
//

import AuthenticationServices
import UIKit

final class LoginViewController: BaseViewController {

    private let welcomeLabel = UILabel()
    private let loginButton = ASAuthorizationAppleIDButton(type: .continue, style: .white)

    override func setupUI() {
        view.backgroundColor = .backgroundColor

        welcomeLabel.do {
            $0.text = "Welcome to Millisecond"
            $0.font = .systemFont(ofSize: 40, weight: .heavy)
            $0.textColor = .white
            $0.textAlignment = .center
        }
    }

    override func setupSubviews() {
        view.addSubview(loginButton)
    }

    override func setConstraints() {
        loginButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalTo(16)
            $0.height.equalTo(50)
        }
    }
}
