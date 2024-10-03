//
//  LoginIntroViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/30/24.
//

import UIKit

import Lottie
import RxSwift

final class LoginIntroViewController: BaseViewController {

    // MARK: - Properties

    private let viewModel = LoginIntroViewModel()

    private let welcomeLabel = UILabel()
    private let thunderAnimationView = LottieAnimationView(name: "thunder")
    private let timerAnimationView = LottieAnimationView(name: "timer")
    private let emailLoginButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        emailLoginButton.rx.tap
            .bind(to: viewModel.input.emailLoginTapped)
            .disposed(by: disposeBag)

        viewModel.output.navigateToLogin
            .drive(onNext: { [weak self] in
                self?.navigateToLoginVC()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Helpers

    private func navigateToLoginVC() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
        navigationController?.navigationBar.topItem?.title = ""
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - UI

    override func setupUI() {
        view.backgroundColor = .backgroundColor

        welcomeLabel.do {
            $0.text = "Millisecond"
            $0.font = .systemFont(ofSize: 60, weight: .heavy)
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

        emailLoginButton.do {
            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "envelope")
            config.imagePlacement = .leading
            config.imagePadding = 5
            config.baseForegroundColor = .black
            config.baseBackgroundColor = .white

            $0.configuration = config
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "Email로 로그인",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                        .foregroundColor: UIColor.black
                    ]
                ),
                for: .normal
            )
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
        }
    }

    override func setupSubviews() {
        [welcomeLabel, thunderAnimationView, timerAnimationView, emailLoginButton].forEach {
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

        emailLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            $0.width.equalTo(343)
            $0.height.equalTo(56)
        }
    }
}
