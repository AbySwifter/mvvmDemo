//
//  PersonalViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/23.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PersonalViewModel: MVVMViewModel {

    override var outputType: MVVMOutput.Type? { return PersonalOutput.self }

    private var user = BehaviorRelay<User>.init(value: UserShared.shared.userInfo) // 用户信息的Observable
    private var avatarTapSubject = PublishSubject<Void>.init()
    private var data = BehaviorRelay<PersonPageData>.init(value: PersonPageData.init())

    private var changeLoginStatus = PublishSubject<UserShared.LoginStatus>.init() // 更改登录状态

    /// 网络请求的快捷键
    func getUserInfo() {
        guard let session = UserShared.shared.sign.userSession else { return }
        // 请求个人数据
        Network.provider.rx.request(Api.userInfo(session))
            .asObservable()
            .mapModel(BaseResponseModel<PersonPageData>.self)
            .subscribe { (event) in
                switch event {
                case .next(let model):
                    if let userData = model.data {
                        guard let user = userData.userInfo else { return }
                        user.saveUserInfo() // 保存用户信息
                        UserShared.shared.userInfo = user // 全局处理
                        self.user.accept(user)    // 发出User事件
                    }
                case .error(let error):
                    DTLog(error.localizedDescription)
                case .completed:
                    break
                }
        }.disposed(by: self.bag)
    }

    override func provideOutput() -> MVVMOutput? {
        let output = PersonalOutput.init(viewModel: self)
        let input = self.input as! PersonalInput
        // 由input订阅 用户信息的变更和登录状态的变更
        input.updateUserInfoDriver.asDriver(onErrorJustReturn: ()).drive(onNext: { () in
            self.getUserInfo()
        }, onCompleted: nil, onDisposed: nil).disposed(by: self.bag)
        return output
    }

    struct PersonalOutput: MVVMOutput {
        init(viewModel: MVVMViewModel) {
            let viewModel = viewModel as! PersonalViewModel
            self.avatar = viewModel.user.asDriver().map { (user) -> URL? in
                return URL.init(string: user.avatar)
                }.asDriver()
            self.name = viewModel.user.asDriver().map { (user) -> String in
                return user.name
                }.asDriver()
            self.listData = viewModel.data.asDriver().map { (model) -> [PersonPageData.PersonalItem] in
                return model.items
                }.asDriver()
        }
        let avatar: Driver<URL?>
        let name: Driver<String>
        let listData: Driver<[PersonPageData.PersonalItem]>
    }
}
