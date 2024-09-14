//
//  HomeViewModel.swift
//  Millisecond
//
//  Created by RAFA on 9/13/24.
//

import RxSwift
import RxCocoa

final class HomeViewModel {

    // MARK: - Input/Output

    struct Input {
        let startButtonTapped: PublishRelay<Void>
    }

    struct Output {
        let navigateToGameVC: Driver<Void>
    }

    // MARK: - Properties

    let input: Input
    let output: Output

    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        let startButtonTapped = PublishRelay<Void>()
        
        self.input = Input(startButtonTapped: startButtonTapped)
        self.output = HomeViewModel.transform(input: input)
    }

    // MARK: - Helpers

    private static func transform(input: Input) -> Output {
        let navigateToGameVC = input.startButtonTapped
            .asDriver(onErrorDriveWith: .empty())

        return Output(navigateToGameVC: navigateToGameVC)
    }
}
