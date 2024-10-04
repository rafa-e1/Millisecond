//
//  HomeViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/13/24.
//

import UIKit

final class HomeViewController: BaseViewController {

    // MARK: - Properties

    private let startButton = UIButton(type: .system)
    private let viewModel: HomeViewModel

    // MARK: - Initializer

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        bind()
    }

    // MARK: - Bindings

    private func bind() {
        startButton.rx.tap
            .bind(to: viewModel.input.startButtonTapped)
            .disposed(by: disposeBag)

        viewModel.output.navigateToGameVC
            .drive(onNext: { [weak self] in
                self?.navigateToGameVC()
            }).disposed(by: disposeBag)
    }

    // MARK: - Helpers

    private func navigateToGameVC() {
        let gameVC = GameViewController()
        let navigationController = UINavigationController(rootViewController: gameVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    // MARK: - UI

    override func setupUI() {
        startButton.do {
            $0.backgroundColor = .white
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "시작하기",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                        .foregroundColor: UIColor.black
                    ]
                ),
                for: .normal
            )
        }
    }

    override func setupSubviews() {
        view.addSubview(startButton)
    }

    override func setConstraints() {
        startButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalTo(16)
            $0.height.equalTo(50)
        }
    }
}
