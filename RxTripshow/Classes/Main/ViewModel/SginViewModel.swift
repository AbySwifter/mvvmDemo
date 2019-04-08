//
//  SginViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/24.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignViewModel {
    let input: SignViewModel.SignInput
    let output: SignViewModel.SignOutPut

    private let nameSubject = BehaviorSubject<String>.init(value: "")
    private let pwdSubject = BehaviorSubject<String>.init(value: "")
    init() {
        self.input = Input.init(username: nameSubject.asObserver(), password: pwdSubject.asObserver())
        let usernameValid = nameSubject.asObservable().map { (string) -> Bool in
            return string.count != 0
        }.share(replay: 1).asDriver(onErrorJustReturn: false)
        let passwordValid = pwdSubject.asObservable().map { (string) -> Bool in
            return string.count != 0
        }.share(replay: 1).asDriver(onErrorJustReturn: false)
        let everything = Observable.combineLatest(usernameValid.asObservable(), passwordValid.asObservable()) { (r1: Bool, r2: Bool) -> Bool in
            return r1 && r2
        }.share(replay: 1).asDriver(onErrorJustReturn: false)
        self.output = Output.init(usernameValid: usernameValid, passwordValid: passwordValid, everyThingValid: everything)
    }
}

extension SignViewModel: AbyViewModelType {
    typealias Input = SignInput
    typealias Output = SignOutPut

    struct SignInput {
        let username: AnyObserver<String>
        let password: AnyObserver<String>
    }

    struct SignOutPut {
        let usernameValid: Driver<Bool>
        let passwordValid: Driver<Bool>
        let everyThingValid: Driver<Bool>
    }
}
