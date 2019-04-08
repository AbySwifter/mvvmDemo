//
//  UserModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/23.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import HandyJSON

struct User: HandyJSON {

    private let userStoreKey = "userInfo"

    var name: String = "请登录"
    var avatar: String = ""

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &name, name: "NickName")
        mapper.specify(property: &avatar, name: "HeadImageUrl")
    }

    func saveUserInfo() {
        let info = self.toJSONString()
        UserDefaults.standard.set(info, forKey: userStoreKey)
    }

    // 加载UserInfo，如果没有表示没有登录
    static func loadUserInfo() -> User {
        guard let info = UserDefaults.standard.string(forKey: "userInfo") else {
            return User.init(name: "请登录", avatar: "")
        }
        return User.deserialize(from: info) ?? User.init(name: "请登录", avatar: "")
    }
}

struct PersonPageData: HandyJSON {

    typealias PersonalItem = (UIImage, String)

    var userInfo: User?
    var pages: Array<String>?

    let items: [PersonalItem] = [
        (#imageLiteral(resourceName: "thumbs-up-no-select"), "喜欢"),
        (#imageLiteral(resourceName: "cache_icon"), "离线缓存"),
        (#imageLiteral(resourceName: "setting_icon"), "设置"),
        (#imageLiteral(resourceName: "problems"), "举报与反馈")
    ]

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &userInfo, name: "UserInfo")
        mapper.specify(property: &pages, name: "Pages")
    }
}
