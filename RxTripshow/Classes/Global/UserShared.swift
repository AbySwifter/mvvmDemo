//
//  UserShared.swift
//  RxTripshow
//
//  Created by aby on 2018/8/30.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

class UserShared {
    // 登录的状态
    enum LoginStatus {
        case loginIn
        case loginOut
    }

    static let shared = UserShared.init()
    private init() {
        sign = SignModel.init()
        sign.loadUserSession()
        userInfo = User.loadUserInfo() // 获取用户信息
    }
    var sign: SignModel
    var userInfo: User

    var loginStatus: LoginStatus {
        sign.loadUserSession() // 加载登录信息
        if sign.userSession == nil {
            return .loginOut
        } else {
            return .loginIn
        }
    }
}
