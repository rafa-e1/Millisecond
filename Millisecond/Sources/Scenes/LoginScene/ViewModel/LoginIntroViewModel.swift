//
//  LoginIntroViewModel.swift
//  Millisecond
//
//  Created by RAFA on 10/2/24.
//

import RxSwift

final class LoginIntroViewModel: NSObject {

    // MARK: - Input/Output

    struct Input {
        let emailLoginTapped: PublishSubject<Void>
    }

    struct Output {
        let signInSuccess: PublishSubject<Bool>
        let errorMessage: PublishSubject<String>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    override init() {
        let emailLoginTapped = PublishSubject<Void>()
        let signInSuccess = PublishSubject<Bool>()
        let errorMessage = PublishSubject<String>()

        self.input = Input(emailLoginTapped: emailLoginTapped)
        self.output = Output(signInSuccess: signInSuccess, errorMessage: errorMessage)

        super.init()

        bindInput()
    }

    // MARK: - Helpers

    private func bindInput() {
        input.emailLoginTapped
            .subscribe(onNext: { [weak self] in
                
            })
            .disposed(by: disposeBag)
    }
}
