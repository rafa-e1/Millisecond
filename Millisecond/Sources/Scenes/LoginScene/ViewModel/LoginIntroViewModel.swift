//
//  LoginIntroViewModel.swift
//  Millisecond
//
//  Created by RAFA on 10/2/24.
//

import RxCocoa
import RxSwift

final class LoginIntroViewModel {

    // MARK: - Input/Output

    struct Input {
        let emailLoginTapped: PublishRelay<Void>
    }

    struct Output {
        let signInSuccess: Driver<Bool>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        let emailLoginTapped = PublishRelay<Void>()
        let signInSuccess = signInSuccessRelay.asDriver(onErrorJustReturn: false)

        self.input = Input(emailLoginTapped: emailLoginTapped)
        self.output = Output(signInSuccess: signInSuccess, errorMessage: errorMessage)
    }
}
