//
//  LoginViewController.swift
//  Millisecond
//
//  Created by RAFA on 10/3/24.
//

import UIKit

final class LoginViewController: BaseViewController {

    // MARK: - Properties

    private let emailTextField = CustomTextField(placeholder: "이메일", isSecure: false)
    private let pwTextField = CustomTextField(placeholder: "비밀번호", isSecure: true)
    private let loginButton = UIButton(type: .system)
    private let stackView = UIStackView()
    private let signUpButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Actions

    @objc private func navigateToSignUpVC() {
        let controller = SignUpViewController()
        navigationController?.pushViewController(controller, animated: true)
        navigationController?.navigationBar.topItem?.title = ""
    }

    // MARK: - Helpers

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - UI

    override func setupUI() {
        loginButton.do {
            $0.backgroundColor = .white
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "로그인하기",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                        .foregroundColor: UIColor.black
                    ]
                ),
                for: .normal
            )
        }

        stackView.do {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 10
            $0.addArrangedSubview(emailTextField)
            $0.addArrangedSubview(pwTextField)
            $0.addArrangedSubview(loginButton)
        }

        signUpButton.do {
            $0.attributedTitle(
                firstPart: "계정이 없으신가요? ", .white,
                secondPart: "계정 생성하기", .systemBlue
            )

            $0.addTarget(self, action: #selector(navigateToSignUpVC), for: .touchUpInside)
        }

        activityIndicator.do {
            $0.color = .systemYellow
            $0.hidesWhenStopped = true
        }
    }

    override func setupSubviews() {
        [stackView, signUpButton, activityIndicator].forEach {
            view.addSubview($0)
        }
    }

    override func setConstraints() {
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.left.right.equalToSuperview().inset(16)
        }

        signUpButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(5)
            $0.height.equalTo(50)
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
