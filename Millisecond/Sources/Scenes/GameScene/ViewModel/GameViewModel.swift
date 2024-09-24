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
        let guideText: Driver<String>
        let reactionTimeHistory: Driver<[String]>
        let averageReactionTime: Driver<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    let gameStateRelay = BehaviorRelay<GameState>(value: .red)

    private let testCounterRelay = BehaviorRelay<Int>(value: 0)
    private let guideTextRelay = BehaviorRelay<String>(value: GameState.red.guideText)
    private let reactionTimeHistoryRelay = BehaviorRelay<[String]>(value: [])
    private let averageReactionTimeRelay = BehaviorRelay<String>(value: "N/A")

    private var startTime: Date?
    private var timerDisposable: Disposable?
    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        let startTest = PublishRelay<Void>()
        let stateChanged = PublishRelay<GameState>()

        self.input = Input(
            startTest: startTest,
            stateChanged: stateChanged
        )

        self.output = GameViewModel.transform(
            input: input,
            gameStateRelay: gameStateRelay,
            testCounterRelay: testCounterRelay,
            guideTextRelay: guideTextRelay,
            reactionTimeHistoryRelay: reactionTimeHistoryRelay,
            averageReactionTimeRelay: averageReactionTimeRelay
        )

        bindInput()
    }

    // MARK: - Helpers

    private func bindInput() {
        input.startTest
            .bind { [weak self] in
                self?.prepareForTest()
            }
            .disposed(by: disposeBag)

        input.stateChanged
            .bind { [weak self] newState in
                self?.handleStateChange(newState)
            }
            .disposed(by: disposeBag)
    }

    private func handleStateChange(_ state: GameState) {
        switch state {
        case .red: resetTest()
        case .orange: resetAllTests()
        case .green: startTest()
        case .result: handleTestResult()
        }
        guideTextRelay.accept(state.guideText)
    }

    private static func transform(
        input: Input,
        gameStateRelay: BehaviorRelay<GameState>,
        testCounterRelay: BehaviorRelay<Int>,
        guideTextRelay: BehaviorRelay<String>,
        reactionTimeHistoryRelay: BehaviorRelay<[String]>,
        averageReactionTimeRelay: BehaviorRelay<String>
    ) -> Output {
        return Output(
            gameState: gameStateRelay.asDriver(onErrorJustReturn: .red),
            testCounter: testCounterRelay.asDriver(onErrorJustReturn: 0),
            guideText: guideTextRelay.asDriver(onErrorJustReturn: GameState.red.guideText),
            reactionTimeHistory: reactionTimeHistoryRelay.asDriver(onErrorJustReturn: []),
            averageReactionTime: averageReactionTimeRelay.asDriver(onErrorJustReturn: "N/A")
        )
    }
}

private extension GameViewModel {

    func prepareForTest() {
        resetTest()

        let randomDelay = Double.random(in: 1.0...5.0)

        timerDisposable?.dispose()

        timerDisposable = Observable<Int>.timer(
            .seconds(Int(randomDelay)),
            scheduler: MainScheduler.instance
        )
        .subscribe(onNext: { [weak self] _ in
            self?.startTest()
        })

        timerDisposable?.disposed(by: disposeBag)
    }

    func startTest() {
        gameStateRelay.accept(.green)
        startTime = Date()
    }

    func resetTest() {
        if testCounterRelay.value >= 5 {
            resetTestCountAndHistory()
        }

        timerDisposable?.dispose()
        gameStateRelay.accept(.red)
    }

    func resetTestCountAndHistory() {
        testCounterRelay.accept(0)
        reactionTimeHistoryRelay.accept([])
        averageReactionTimeRelay.accept("N/A")
    }

    func resetAllTests() {
        timerDisposable?.dispose()
        gameStateRelay.accept(.orange)
        testCounterRelay.accept(0)
        reactionTimeHistoryRelay.accept([])
        averageReactionTimeRelay.accept("N/A")
    }

    func handleTestResult() {
        guard let startTime else { return }

        gameStateRelay.accept(.result)

        let reactionTime = Date().timeIntervalSince(startTime) * 1_000
        let newCount = testCounterRelay.value + 1

        var history = reactionTimeHistoryRelay.value
        history.append(String(format: "\(newCount). 반응속도: %.0fms", reactionTime))
        reactionTimeHistoryRelay.accept(history)

        testCounterRelay.accept(newCount)

        if newCount == 5 {
            calculateAverageReactionTime()
        }
    }

    func calculateAverageReactionTime() {
        let reactionTimes = reactionTimeHistoryRelay.value.compactMap {
            Double(
                $0.components(separatedBy: " ")
                    .last?
                    .replacingOccurrences(of: "ms", with: "") ?? ""
            )
        }

        guard !reactionTimes.isEmpty else { return }

        let average = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        averageReactionTimeRelay.accept(String(format: "평균 반응속도: %.0fms", average))
    }
}
