//
//  SignModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/28.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import HandyJSON

struct SignModel: HandyJSON {
    // 用它来标志是否登录
    var userSession: String?

    func saveUserSession() {
        UserDefaults.standard.set(userSession, forKey: "userSession")
    }

    mutating func loadUserSession() {
        guard let userSession = UserDefaults.standard.string(forKey: "userSession") else {
            return
        }
        self.userSession = userSession
    }
}
