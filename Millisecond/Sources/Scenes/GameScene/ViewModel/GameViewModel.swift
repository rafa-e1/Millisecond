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
        let reactionTimeText: Driver<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output
    let gameStateRelay = BehaviorRelay<GameState>(value: .red)

    private var testCounterRelay = BehaviorRelay<Int>(value: 0)
    private let currentGuideTextRelay = BehaviorRelay<GameGuideText>(value: .restartPrompt)
    private let reactionTimeTextRelay = BehaviorRelay<String>(value: "")
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
            reactionTimeTextRelay: reactionTimeTextRelay
        )

        bindInput()
    }

    // MARK: - Helpers

    func startTest() {
        if testCounterRelay.value >= 5 {
            testCounterRelay.accept(0)
        }

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
                reactionTimeTextRelay.accept(String(format: "반응속도: %.0fms", reactionTime))

                let newCount = testCounterRelay.value + 1
                testCounterRelay.accept(newCount)
            }
        }
    }

    private func resetState() {
        timerDisposable?.dispose()
        gameStateRelay.accept(.red)
        currentGuideTextRelay.accept(.startPrompt)
        reactionTimeTextRelay.accept("")
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
        reactionTimeTextRelay: BehaviorRelay<String>
    ) -> Output {
        let gameState = gameStateRelay.asDriver(onErrorDriveWith: .empty())
        let testCounter = testCounterRelay.asDriver(onErrorDriveWith: .empty())
        let currentGuideText = currentGuideTextRelay.asDriver(onErrorDriveWith: .empty())
        let reactionTimeText = reactionTimeTextRelay.asDriver(onErrorDriveWith: .empty())

        return Output(
            gameState: gameState,
            testCounter: testCounter,
            currentGuideText: currentGuideText,
            reactionTimeText: reactionTimeText
        )
    }
}

// TODO: 개선
/*
 - 결과(1/5)로 테스트 횟수 업데이트하기
    - orange 상태일 때 결과 횟수 0으로 초기화
    - result 상태일 때 결과 횟수 +1
    - 5/5가 되었을 때 재시작 버튼 누르면 0으로 초기화
 - 반응속도 위에 '프로선수하셔도 되겠어요!'와 같은 텍스트 모델 생성하기
 - 총 5번의 테스트가 끝나면 총 기록들을 순서대로 나열하기
 - 나열한 기록들 아래에 평균값 넣기
 - '결과' 텍스트 지우고  '프로선수급', '국가권력급'과 같은 칭호 타이틀로 업데이트하기
 - 나가기 버튼 클릭 시 재확인 경고창 띄우기(ex. 지금까지 진행된 기록들이 모두 사라집니다. 정말 나가시겠습니까?)
 - 총 5번의 테스트를 진행했을 땐 바로 나가지도록 설정
 - 홈 화면에 테스트로부터 얻은 칭호 타이틀 보이도록 하기
 - 오늘 최고기록과 올타임 최고기록 표시하기
 - 유저들 TOP 1부터 TOP 100까지 표시하는 탭 생성하기
 - 내가 얻은 타이틀 모두 볼 수 있는 탭 생성하기
 - 나가기 버튼 아이콘 추가하기
 */
