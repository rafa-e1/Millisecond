//
//  LoginViewModel.swift
//  Millisecond
//
//  Created by RAFA on 10/3/24.
//

import UIKit

import RxCocoa
import RxSwift

final class LoginViewModel {

    // MARK: - Input/Output

    struct Input {
        let email: BehaviorRelay<String>
        let password: BehaviorRelay<String>
        let nickname: BehaviorRelay<String>
    }

    struct Output {
        let isFormValid: Driver<Bool>
        let buttonBackgroundColor: Driver<UIColor>
        let buttonTintColor: Driver<UIColor>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        let emailRelay = BehaviorRelay<String>(value: "")
        let passwordRelay = BehaviorRelay<String>(value: "")
        let nicknameRelay = BehaviorRelay<String>(value: "")

        let isFormValid = Observable
            .combineLatest(emailRelay, passwordRelay, nicknameRelay)
            .map { email, password, nickname in
                return !email.isEmpty && !password.isEmpty && !nickname.isEmpty
            }
            .asDriver(onErrorJustReturn: false)

        let buttonBackgroundColor = isFormValid
            .map { $0 ? UIColor.white : .white.withAlphaComponent(0.2) }
            .asDriver()

        let buttonTintColor = isFormValid
            .map { $0 ? UIColor.black : .black.withAlphaComponent(0.67) }
            .asDriver()

        self.input = Input(
            email: emailRelay,
            password: passwordRelay,
            nickname: nicknameRelay
        )

        self.output = Output(
            isFormValid: isFormValid,
            buttonBackgroundColor: buttonBackgroundColor,
            buttonTintColor: buttonTintColor
        )
    }
}
