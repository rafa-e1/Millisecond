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
        let resultText: Driver<String>
        let guideText: Driver<String>
        let reactionTimeHistory: Driver<[String]>
        let averageReactionTime: Driver<String>
        let resetProgressBar: Signal<Void>
        let rankText: Driver<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    let gameStateRelay = BehaviorRelay<GameState>(value: .red)

    private let testCounterRelay = BehaviorRelay<Int>(value: 0)
    private let resultTextRelay = BehaviorRelay<String>(value: "N/A")
    private let guideTextRelay = BehaviorRelay<String>(value: GameState.red.guideText)
    private let reactionTimeHistoryRelay = BehaviorRelay<[String]>(value: [])
    private let averageReactionTimeRelay = BehaviorRelay<String>(value: "N/A")
    private let resetProgressBarRelay = PublishRelay<Void>()
    private let rankTextRelay = BehaviorRelay<String>(value: "")

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
            resultTextRelay: resultTextRelay,
            guideTextRelay: guideTextRelay,
            reactionTimeHistoryRelay: reactionTimeHistoryRelay,
            averageReactionTimeRelay: averageReactionTimeRelay,
            resetProgressBarRelay: resetProgressBarRelay,
            rankTextRelay: rankTextRelay
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
        gameStateRelay.accept(state)
        guideTextRelay.accept(state.guideText)

        switch state {
        case .red: resetTest()
        case .orange: resetAllTests()
        case .green: startTest()
        case .result: handleTestResult()
        }
    }

    private static func transform(
        input: Input,
        gameStateRelay: BehaviorRelay<GameState>,
        testCounterRelay: BehaviorRelay<Int>,
        resultTextRelay: BehaviorRelay<String>,
        guideTextRelay: BehaviorRelay<String>,
        reactionTimeHistoryRelay: BehaviorRelay<[String]>,
        averageReactionTimeRelay: BehaviorRelay<String>,
        resetProgressBarRelay: PublishRelay<Void>,
        rankTextRelay: BehaviorRelay<String>
    ) -> Output {
        return Output(
            gameState: gameStateRelay.asDriver(onErrorJustReturn: .red),
            testCounter: testCounterRelay.asDriver(onErrorJustReturn: 0),
            resultText: resultTextRelay.asDriver(onErrorJustReturn: "N/A"),
            guideText: guideTextRelay.asDriver(onErrorJustReturn: GameState.red.guideText),
            reactionTimeHistory: reactionTimeHistoryRelay.asDriver(onErrorJustReturn: []),
            averageReactionTime: averageReactionTimeRelay.asDriver(onErrorJustReturn: "N/A"),
            resetProgressBar: resetProgressBarRelay.asSignal(),
            rankText: rankTextRelay.asDriver(onErrorJustReturn: "")
        )
    }
}

private extension GameViewModel {

    func prepareForTest() {
        resetTest()
        setTimerWithRandomDelay()
    }

    func startTest() {
        gameStateRelay.accept(.green)
        guideTextRelay.accept(GameState.green.guideText)
        startTime = Date()
    }

    func resetTest() {
        if testCounterRelay.value >= 5 {
            resetTestCountAndHistory()
        }

        timerDisposable?.dispose()
        gameStateRelay.accept(.red)
        guideTextRelay.accept(GameState.red.guideText)
    }

    func resetTestCountAndHistory() {
        testCounterRelay.accept(0)
        reactionTimeHistoryRelay.accept([])
        averageReactionTimeRelay.accept("N/A")
        resetProgressBarRelay.accept(())
    }

    func resetAllTests() {
        timerDisposable?.dispose()
        gameStateRelay.accept(.orange)
        guideTextRelay.accept(GameState.orange.guideText)
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
        resultTextRelay.accept(String(format: "%.0fms", reactionTime))
        reactionTimeHistoryRelay.accept(history)
        testCounterRelay.accept(newCount)

        if newCount == 5 {
            calculateAverageReactionTime()

            let averageTime = reactionTimeHistoryRelay.value.compactMap {
                Double($0.components(separatedBy: " ")
                    .last?
                    .replacingOccurrences(of: "ms", with: "") ?? "")
            }.reduce(0, +) / Double(reactionTimeHistoryRelay.value.count)

            let rank = Scoreboard.calculateScore(from: averageTime)
            rankTextRelay.accept(rank)
        }
    }

    func setTimerWithRandomDelay() {
        let randomDelay = Double.random(in: 1.0...1.0)

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
