//
//  SignUpViewController.swift
//  Millisecond
//
//  Created by RAFA on 10/3/24.
//

import UIKit

final class SignUpViewController: BaseViewController {

    // MARK: - Properties

    private var isKeyboardAlreadyShown = false

    private let addPhotoButton = UIButton(type: .system)
    private var textFields: [UITextField] = []
    private let nicknameTextField = CustomTextField(placeholder: "닉네임", isSecure: false)
    private let emailTextField = CustomTextField(placeholder: "이메일", isSecure: false)
    private let pwTextField = CustomTextField(placeholder: "비밀번호", isSecure: true)
    private let confirmPasswordTextField = CustomTextField(placeholder: "비밀번호 확인", isSecure: true)
    private let createButton = UIButton(type: .system)
    private let credentialsStackView = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextFieldDelegate()
        registerKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Actions

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if !isKeyboardAlreadyShown {
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = .black.withAlphaComponent(0.8)
                self.addPhotoButton.alpha = 0.1
                self.view.bringSubviewToFront(self.credentialsStackView)
            }
            isKeyboardAlreadyShown = true
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .backgroundColor
            self.addPhotoButton.alpha = 1
        }
        isKeyboardAlreadyShown = false
    }

    // MARK: - Helpers

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI

    override func setupUI() {
        addPhotoButton.do {
            $0.setImage(
                UIImage(systemName: "plus")?
                    .withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
                    .withConfiguration(
                        UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
                    ),
                for: .normal
            )
            $0.layer.cornerRadius = 180 / 2
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
        }

        createButton.do {
            $0.backgroundColor = .white
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "생성하기",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                        .foregroundColor: UIColor.black
                    ]
                ),
                for: .normal
            )
        }

        credentialsStackView.do {
            $0.axis = .vertical
            $0.distribution = .fillEqually
            $0.spacing = 10
            $0.addArrangedSubview(nicknameTextField)
            $0.addArrangedSubview(emailTextField)
            $0.addArrangedSubview(pwTextField)
            $0.addArrangedSubview(confirmPasswordTextField)
            $0.addArrangedSubview(createButton)
        }

        activityIndicator.do {
            $0.color = .systemYellow
            $0.hidesWhenStopped = true
        }
    }

    override func setupSubviews() {
        [addPhotoButton, credentialsStackView, activityIndicator].forEach {
            view.addSubview($0)
        }
    }

    override func setConstraints() {
        addPhotoButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.size.equalTo(180)
        }

        credentialsStackView.snp.makeConstraints {
            $0.centerX.equalTo(addPhotoButton)
            $0.top.lessThanOrEqualTo(addPhotoButton.snp.bottom).offset(20)
            $0.left.equalTo(10)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {

    private func configureTextFieldDelegate() {
        textFields = [
            nicknameTextField,
            emailTextField,
            pwTextField,
            confirmPasswordTextField
        ]

        textFields.forEach { $0.delegate = self }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nicknameTextField: emailTextField.becomeFirstResponder()
        case emailTextField: pwTextField.becomeFirstResponder()
        case pwTextField: confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField: confirmPasswordTextField.resignFirstResponder()
        default: nicknameTextField.becomeFirstResponder()
        }

        return true
    }
}
