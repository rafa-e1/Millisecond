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
        let testCounter: Driver<Int>
        let currentGuideText: Driver<GameGuideText>
        let reactionTimeHistory: Driver<[String]>
        let averageReactionTime: Driver<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output
    let gameStateRelay = BehaviorRelay<GameState>(value: .red)

    var testCounterRelay = BehaviorRelay<Int>(value: 0)
    private let currentGuideTextRelay = BehaviorRelay<GameGuideText>(value: .restartPrompt)
    private let reactionTimeHistoryRelay = BehaviorRelay<[String]>(value: [])
    private let averageReactionTimeRelay = BehaviorRelay<String>(value: "N/A")
    private var startTime: Date?
    private var timerDisposable: Disposable?
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
            testCounterRelay: testCounterRelay,
            currentGuideTextRelay: currentGuideTextRelay,
            reactionTimeHistoryRelay: reactionTimeHistoryRelay,
            averageReactionTimeRelay: averageReactionTimeRelay
        )

        bindInput()
    }

    // MARK: - Helpers

    func startTest() {
        resetState()

        let randomDelay = Double.random(in: 1.0...5.0)

        timerDisposable?.dispose()

        timerDisposable = Observable<Int>.timer(
            .seconds(Int(randomDelay)),
            scheduler: MainScheduler.instance
        )
        .subscribe(onNext: { [weak self] _ in
            self?.gameStateRelay.accept(.green)
            self?.startTime = Date()
        })

        timerDisposable?.disposed(by: disposeBag)
    }

    func handleStateChange(_ state: GameState) {
        switch state {
        case .red:
            resetState()
        case .orange:
            timerDisposable?.dispose()
            testCounterRelay.accept(0)
            reactionTimeHistoryRelay.accept([])
            averageReactionTimeRelay.accept("N/A")
            gameStateRelay.accept(.orange)
            currentGuideTextRelay.accept(.restartPrompt)
        case .green:
            startTime = Date()
            gameStateRelay.accept(.green)
        case .result:
            if let startTime = startTime {
                let reactionTime = Date().timeIntervalSince(startTime) * 1_000
                gameStateRelay.accept(.result)
                currentGuideTextRelay.accept(.restartPrompt)

                let newCount = testCounterRelay.value + 1
                testCounterRelay.accept(newCount)

                var history = reactionTimeHistoryRelay.value
                history.append(String(format: "\(newCount). 반응속도: %.0fms", reactionTime))
                reactionTimeHistoryRelay.accept(history)

                if newCount == 5 {
                    calculateAverageReactionTime()
                }
            }
        }
    }

    private func calculateAverageReactionTime() {
        let history = reactionTimeHistoryRelay.value
        let reactionTimes = history.compactMap { entry -> Double? in
            let components = entry.components(separatedBy: " ")
            guard let timeString = components.last?.replacingOccurrences(of: "ms", with: ""),
                  let reactionTime = Double(timeString) else {
                return nil
            }
            return reactionTime
        }

        if reactionTimes.count == 5 {
            let average = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
            averageReactionTimeRelay.accept(String(format: "평균 반응속도: %.0fms", average))
        }
    }

    private func resetState() {
        if testCounterRelay.value >= 5 {
            testCounterRelay.accept(0)
            reactionTimeHistoryRelay.accept([])
            averageReactionTimeRelay.accept("N/A")
        }

        timerDisposable?.dispose()
        gameStateRelay.accept(.red)
        currentGuideTextRelay.accept(.startPrompt)
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
        testCounterRelay: BehaviorRelay<Int>,
        currentGuideTextRelay: BehaviorRelay<GameGuideText>,
        reactionTimeHistoryRelay: BehaviorRelay<[String]>,
        averageReactionTimeRelay: BehaviorRelay<String>
    ) -> Output {
        let gameState = gameStateRelay.asDriver(onErrorDriveWith: .empty())
        let testCounter = testCounterRelay.asDriver(onErrorDriveWith: .empty())
        let currentGuideText = currentGuideTextRelay.asDriver(onErrorDriveWith: .empty())
        let reactionTimeHistory = reactionTimeHistoryRelay.asDriver(onErrorDriveWith: .empty())
        let averageReactionTime = averageReactionTimeRelay.asDriver(onErrorDriveWith: .empty())

        return Output(
            gameState: gameState,
            testCounter: testCounter,
            currentGuideText: currentGuideText,
            reactionTimeHistory: reactionTimeHistory,
            averageReactionTime: averageReactionTime
        )
    }
}
