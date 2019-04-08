//
//  UIViewController+Extension.swift
//  RxTripshow
//
//  Created by aby on 2018/9/5.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

extension UIViewController {
    /// 设置当前VC的导航栏透明
    func setNavigationBarTranslucent() {
        guard let navBar = self.navigationController?.navigationBar else {
            return
        }
        navBar.isTranslucent = true
        let color = UIColor.clear
        let rect = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 64)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        navBar.setBackgroundImage(image, for: .any, barMetrics: .default)
        navBar.clipsToBounds = true
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
        //        self.extendedLayoutIncludesOpaqueBars = true
    }

    /// 设置主题色导航栏
    func setThemeNavigationBar(theme: UIColor) {
        guard let navBar = self.navigationController?.navigationBar else {
            return
        }
        navBar.setBackgroundImage(nil, for: .any, barMetrics: .default)
        navBar.clipsToBounds = false
        navBar.isTranslucent = false
        navBar.barTintColor = theme
        navBar.tintColor = UIColor.white
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
    }

    func setNavigationBar(hide: Bool) {
        self.navigationController?.setNavigationBarHidden(hide, animated: false)
    }
}
