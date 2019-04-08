//
//  AppStyle.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
let S_themeDark = UIColor.hexInt(0x0c0c0c)
let S_themeSelectColor = UIColor.hexInt(0x8ab71b)
let S_themeUnselectColor = UIColor.hexInt(0xaeaeae)
// text
let S_textBlack = UIColor.hexInt(0x333333)
let S_textGray = UIColor.hexInt(0xcccccc)
let S_textWhite = UIColor.hexInt(0xffffff)
// view
let S_tabBackColor = UIColor.hexInt(0x212121)

// border
let S_borderGray = UIColor.hexInt(0xe9e9e9)

protocol AppStyleConfig {
    func setTabStyle()
    func setNavigatorBarStyle()
}

extension AppStyleConfig {
    func setTabStyle() {
         initColorStyle(barTint: S_themeDark, tint: S_themeSelectColor, unselectedTint: S_themeUnselectColor)
    }

    func setNavigatorBarStyle() {
        let navBar = UINavigationBar.appearance()
        navBar.isTranslucent = false
        navBar.barTintColor = S_themeDark
        navBar.tintColor = S_textWhite
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: S_textWhite, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
    }

    private func initColorStyle(barTint: UIColor = UIColor.white, tint: UIColor = UIColor.blue, unselectedTint: UIColor = UIColor.black) {
        let tabBar = UITabBar.appearance()
        tabBar.barTintColor = barTint
        tabBar.tintColor = tint
        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = unselectedTint
    }
}
