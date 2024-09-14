//
//  GameViewModel.swift
//  Millisecond
//
//  Created by RAFA on 9/13/24.
//

import RxSwift
import RxCocoa

final class GameViewModel {

    // MARK: - Input/Output

    struct Input {
        let startTest: PublishRelay<Void>
        let stateChanged: PublishRelay<GameState>
    }

    struct Output {
        let gameState: Driver<GameState>
        let currentGuideText: Driver<GameGuideText>
        let reactionTimeText: Driver<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output
    let gameStateRelay = BehaviorRelay<GameState>(value: .red)

    private let currentGuideTextRelay = BehaviorRelay<GameGuideText>(value: .restartPrompt)
    private let reactionTimeTextRelay = BehaviorRelay<String>(value: "")

    private var startTime: Date?
    private var timer: Timer?

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        let stateChanged = PublishRelay<GameState>()
        let startTest = PublishRelay<Void>()

        self.input = Input(
            startTest: startTest,
            stateChanged: stateChanged
        )

        self.output = GameViewModel.transform(
            input: input,
            gameStateRelay: gameStateRelay,
            currentGuideTextRelay: currentGuideTextRelay,
            reactionTimeTextRelay: reactionTimeTextRelay
        )

        bindInput()
    }

    // MARK: - Helpers

    func startTest() {
        resetState()

        let randomDelay = Double.random(in: 1.0...5.0)
        timer = Timer.scheduledTimer(
            withTimeInterval: randomDelay,
            repeats: false
        ) { [weak self] _ in
            self?.gameStateRelay.accept(.green)
            self?.startTime = Date()
        }
    }

    func handleStateChange(_ state: GameState) {
        switch state {
        case .red:
            resetState()
        case .yellow:
            stopTimer()
            gameStateRelay.accept(.yellow)
            currentGuideTextRelay.accept(.restartPrompt)
        case .green:
            startTime = Date()
            gameStateRelay.accept(.green)
        case .result:
            if let startTime = startTime {
                let reactionTime = Date().timeIntervalSince(startTime) * 1_000
                stopTimer()
                gameStateRelay.accept(.result)
                currentGuideTextRelay.accept(.restartPrompt)
                reactionTimeTextRelay.accept(String(format: "반응속도: %.0fms", reactionTime))
            }
        }
    }

    private func resetState() {
        stopTimer()
        gameStateRelay.accept(.red)
        currentGuideTextRelay.accept(.startPrompt)
        reactionTimeTextRelay.accept("")
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func bindInput() {
        input.startTest
            .bind { [weak self] in
                self?.startTest()
            }
            .disposed(by: disposeBag)

        input.stateChanged
            .bind { [weak self] newState in
                self?.handleStateChange(newState)
            }
            .disposed(by: disposeBag)
    }

    private static func transform(
        input: Input,
        gameStateRelay: BehaviorRelay<GameState>,
        currentGuideTextRelay: BehaviorRelay<GameGuideText>,
        reactionTimeTextRelay: BehaviorRelay<String>
    ) -> Output {
        let gameState = gameStateRelay.asDriver(onErrorDriveWith: .empty())
        let currentGuideText = currentGuideTextRelay.asDriver(onErrorDriveWith: .empty())
        let reactionTimeText = reactionTimeTextRelay.asDriver(onErrorDriveWith: .empty())

        return Output(
            gameState: gameState,
            currentGuideText: currentGuideText,
            reactionTimeText: reactionTimeText
        )
    }
}
