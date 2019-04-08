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

class SignViewModel: MVVMViewModel {

    override var outputType: MVVMOutput.Type? { return SignOutPut.self }
    private let nameSubject = BehaviorSubject<String>.init(value: "")
    private let pwdSubject = BehaviorSubject<String>.init(value: "")
    private let errorSbuject = PublishSubject<String>.init()

    func bindToOutPut() {
        let input = self.input as! SignInput
        input.username.drive(self.nameSubject).disposed(by: bag)
        input.password.drive(self.pwdSubject).disposed(by: bag)
    }

    func provideUserNameVaild() -> Driver<Bool> {
        return nameSubject.asObservable().map { (string) -> Bool in
            return string.count != 0
            }.share(replay: 1).asDriver(onErrorJustReturn: false)
    }

    func providePasswordVaild() -> Driver<Bool> {
        return pwdSubject.asObservable().map { (string) -> Bool in
            return string.count != 0
            }.share(replay: 1).asDriver(onErrorJustReturn: false)
    }

    func provideSignInAction(usernameAndPassword: Driver<(username: String, password: String)>) -> Driver<MVVMView.DriverUIResult> {
         let input = self.input as! SignInput
        return input.signInTap
            .withLatestFrom(usernameAndPassword).flatMapLatest { (user) -> Driver<MVVMView.DriverUIResult> in
                return self.loginAction(user: user)
            }.asDriver(onErrorJustReturn: (false, "登录失败"))
    }

    func loginAction(user: (username: String, password: String)) -> Driver<MVVMView.DriverUIResult> {
        return  Network.provider.rx.request(Api.login(mobile: user.username, pwd: user.password))
            .asObservable()
            .mapModel(BaseResponseModel<SignModel>.self)
            .map { (event) -> (Bool, String) in
                if event.err != 0 {
                    return (false, event.msg)
                } else {
                    if let model: SignModel = event.data {
                       // 处理登录的逻辑，这里发出信号，开始请求用户信息
                        DTLog(model.userSession)
                        model.saveUserSession()
                        return (true, "登录成功")
                    }
                    return (false, "用户信息获取失败")
                }
            }.asDriver(onErrorJustReturn: (false, "登录失败"))
    }
}

extension SignViewModel {
    struct SignOutPut: MVVMOutput {
        let usernameValid: Driver<Bool>
        let passwordValid: Driver<Bool>
        let everyThingValid: Driver<Bool>
        let singInAction: Driver<MVVMView.DriverUIResult>
        init(viewModel: MVVMViewModel) {
            // swiftlint:disable force_cast
            let viewModel = viewModel as! SignViewModel
            usernameValid = viewModel.provideUserNameVaild()
            passwordValid = viewModel.providePasswordVaild()
            everyThingValid = Observable.combineLatest(usernameValid.asObservable(), passwordValid.asObservable()) { (r1: Bool, r2: Bool) -> Bool in
                    return r1 && r2
                }.share(replay: 1).asDriver(onErrorJustReturn: false)
            let usernameAndPassword = Driver.combineLatest(viewModel.nameSubject.asDriver(onErrorJustReturn: ""), viewModel.pwdSubject.asDriver(onErrorJustReturn: "")) { (uName, pwd) -> (username: String, password: String) in
                return (username: uName, password: pwd)
            }
            singInAction = viewModel.provideSignInAction(usernameAndPassword: usernameAndPassword)
        }
    }
}
