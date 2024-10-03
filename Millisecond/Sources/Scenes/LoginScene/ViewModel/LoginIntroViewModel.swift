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
        let errorMessage: Driver<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    private let signInSuccessRelay = PublishRelay<Bool>()
    private let errorMessageRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        let emailLoginTapped = PublishRelay<Void>()
        let signInSuccess = signInSuccessRelay.asDriver(onErrorJustReturn: false)
        let errorMessage = errorMessageRelay.asDriver(onErrorJustReturn: "An error occurred.")

        self.input = Input(emailLoginTapped: emailLoginTapped)
        self.output = Output(signInSuccess: signInSuccess, errorMessage: errorMessage)

        bindInput()
    }

    // MARK: - Helpers

    private func bindInput() {
        input.emailLoginTapped
            .subscribe(onNext: { [weak self] in
                self?.performEmailLogin()
            })
            .disposed(by: disposeBag)
    }

    private func performEmailLogin() {
        let loginSuccess = true

        if loginSuccess {
            signInSuccessRelay.accept(true)
        } else {
            errorMessageRelay.accept("Login failed. Please try again.")
        }
    }
}
