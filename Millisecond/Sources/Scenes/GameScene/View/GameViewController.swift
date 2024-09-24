//
//  GameViewController.swift
//  Millisecond
//
//  Created by RAFA on 9/13/24.
//

import UIKit

final class GameViewController: BaseViewController {

    // MARK: - Properties

    private let segmentedProgressBar = SegmentedProgressBar(numberOfSegments: 5)
    private let resultTitleLabel = UILabel()
    private let testCounterLabel = UILabel()
    private let jokeLabel = UILabel()
    private let guideLabel = UILabel()
    private let reactionTimeHistoryLabel = UILabel()
    private let averageReactionTimeLabel = UILabel()
    private let exitButton = UIButton(type: .system)
    private let viewModel: GameViewModel

    // MARK: - Initializer

    init(viewModel: GameViewModel = GameViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupGestureRecognizers()
        viewModel.input.startTest.accept(())
    }

    // MARK: - Actions

    @objc private func handleTap() {
        let currentState = viewModel.gameStateRelay.value
        switch currentState {
        case .red: viewModel.input.stateChanged.accept(.orange)
        case .orange, .result: viewModel.input.startTest.accept(())
        case .green: viewModel.input.stateChanged.accept(.result)
        }
    }

    @objc private func exitTest() {
        dismiss(animated: true)
    }

    // MARK: - Bindings

    private func bind() {
        viewModel.output.gameState
            .drive(onNext: { [weak self] state in
                self?.updateUI(for: state)
            })
            .disposed(by: disposeBag)

        viewModel.output.testCounter
            .drive(onNext: { [weak self] count in
                self?.progressView.updateProgress(segmentIndex: count - 1, progress: 1.0)
                self?.testCounterLabel.text = "\(count) / 5"
                self?.averageReactionTimeLabel.isHidden = count != 5
            })
            .disposed(by: disposeBag)

        viewModel.output.guideText
            .drive(guideLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.reactionTimeHistory
            .map { $0.joined(separator: "\n") }
            .drive(reactionTimeHistoryLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.averageReactionTime
            .drive(averageReactionTimeLabel.rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: - Gesture Recognizers

    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Helpers

    private func updateUI(for state: GameState) {
        updateVisibility(for: state)
        updateColors(for: state)
    }

    // MARK: - UI

    override func setupUI() {
        view.backgroundColor = .systemRed

        testCounterLabel.do {
            $0.textColor = .white
            $0.textAlignment = .right
            $0.font = .systemFont(ofSize: 17, weight: .bold)
        }

        resultTitleLabel.do {
            $0.text = "결과"
            $0.textColor = .white
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 60, weight: .heavy)
            $0.isHidden = true
        }

        jokeLabel.do {
            $0.text = "꼼수 부리지 마세요."
            $0.textColor = .white.withAlphaComponent(0.6)
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 15, weight: .ultraLight)
            $0.isHidden = true
        }

        guideLabel.do {
            $0.font = .systemFont(ofSize: 24)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.isHidden = true
        }

        reactionTimeHistoryLabel.do {
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.isHidden = true
        }

        averageReactionTimeLabel.do {
            $0.font = .systemFont(ofSize: 30, weight: .heavy)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.isHidden = true
        }

        exitButton.do {
            $0.backgroundColor = .systemRed
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
            $0.setAttributedTitle(
                NSAttributedString(
                    string: "나가기",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 17, weight: .bold),
                        .foregroundColor: UIColor.white
                    ]
                ),
                for: .normal
            )
            $0.isHidden = true
            $0.addTarget(self, action: #selector(exitTest), for: .touchUpInside)
        }
    }

    override func setupSubviews() {
        [progressView,
         testCounterLabel,
         resultTitleLabel,
         jokeLabel,
         guideLabel,
         reactionTimeHistoryLabel,
         averageReactionTimeLabel,
         exitButton].forEach {
            view.addSubview($0)
        }
    }

    override func setConstraints() {
        progressView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.left.equalTo(16)
        }

        testCounterLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(progressView.snp.bottom).offset(5)
            $0.left.equalTo(progressView).offset(10)
        }

        resultTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(testCounterLabel.snp.bottom).offset(10)
            $0.left.equalTo(testCounterLabel)
        }

        jokeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(resultTitleLabel.snp.bottom).offset(26)
            $0.left.equalTo(resultTitleLabel)
        }

        guideLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(jokeLabel.snp.bottom).offset(10)
            $0.left.equalTo(jokeLabel)
        }

        reactionTimeHistoryLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalTo(guideLabel)
        }

        averageReactionTimeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(reactionTimeHistoryLabel.snp.bottom).offset(30)
            $0.left.equalTo(reactionTimeHistoryLabel)
        }

        exitButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.equalTo(reactionTimeHistoryLabel)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.height.equalTo(50)
        }
    }
}

// MARK: - UI Helpers

private extension GameViewController {

    func updateVisibility(for state: GameState) {
        [resultTitleLabel,
         jokeLabel,
         guideLabel,
         reactionTimeHistoryLabel,
         averageReactionTimeLabel,
         exitButton].forEach {
            $0.isHidden = true
        }

        switch state {
        case .red:
            progressView.isHidden = false
            testCounterLabel.isHidden = false
            guideLabel.isHidden = false
        case .orange:
            progressView.isHidden = true
            testCounterLabel.isHidden = true
            jokeLabel.isHidden = false
            guideLabel.isHidden = false
            exitButton.isHidden = false
        case .green:
            break
        case .result:
            progressView.isHidden = false
            testCounterLabel.isHidden = false
            resultTitleLabel.isHidden = false
            guideLabel.isHidden = false
            reactionTimeHistoryLabel.isHidden = false
            exitButton.isHidden = false
        }
    }

    func updateColors(for state: GameState) {
        switch state {
        case .red:
            view.backgroundColor = .systemRed
            guideLabel.textColor = .white
        case .orange:
            view.backgroundColor = .systemYellow
            guideLabel.textColor = .black
        case .green:
            view.backgroundColor = .systemGreen
        case .result:
            view.backgroundColor = .systemGreen
            guideLabel.textColor = .white
            reactionTimeHistoryLabel.textColor = .white
            averageReactionTimeLabel.textColor = .white
        }
    }
}
