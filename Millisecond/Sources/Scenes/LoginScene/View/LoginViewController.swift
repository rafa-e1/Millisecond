//
//  LoginViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/30/24.
//

import AuthenticationServices
import UIKit

import Lottie

final class LoginViewController: BaseViewController {

    private let welcomeLabel = UILabel()
    private let thunderAnimationView = LottieAnimationView(name: "thunder")
    private let timerAnimationView = LottieAnimationView(name: "timer")
    private let appleSignInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)

    override func setupUI() {
        view.backgroundColor = .backgroundColor

        welcomeLabel.do {
            $0.text = "Welcome"
            $0.font = .systemFont(ofSize: 70, weight: .heavy)
            $0.textColor = .white
            $0.textAlignment = .center
        }

        thunderAnimationView.do {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
            $0.play()
        }

        timerAnimationView.do {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
            $0.play()
        }
    }

    override func setupSubviews() {
        [welcomeLabel, thunderAnimationView, timerAnimationView, appleSignInButton].forEach {
            view.addSubview($0)
        }
    }

    override func setConstraints() {
        welcomeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.left.equalTo(16)
        }

        thunderAnimationView.snp.makeConstraints {
            $0.centerX.equalToSuperview().dividedBy(1.6)
            $0.centerY.equalToSuperview().dividedBy(1.1)
            $0.size.equalTo(300)
        }

        timerAnimationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(250)
        }

        appleSignInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            $0.width.equalTo(343)
            $0.height.equalTo(56)
        }
    }
}
