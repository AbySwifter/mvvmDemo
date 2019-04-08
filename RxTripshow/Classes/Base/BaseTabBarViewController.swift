//
//  BaseTabBarViewController.swift
//  RxTripshow
//
//  Created by aby on 2018/8/17.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController, AppStyleConfig {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabStyle()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 外观是可以配置的
    func initColorStyle(barTint: UIColor = UIColor.white, tint: UIColor = UIColor.blue, unselectedTint: UIColor = UIColor.black) {
        let tabBar = UITabBar.appearance()
        tabBar.barTintColor = barTint
        tabBar.tintColor = tint
        tabBar.unselectedItemTintColor = unselectedTint
    }

    /**
     # 初始化子控制器
     
     - parameter VCConfig: 初始化的子控制器配置
     */
    func add(childController: UIViewController, title: String, icon: UIImage, selectedIcon: UIImage? = nil) {
        childController.tabBarItem.image = icon
        childController.tabBarItem.selectedImage = selectedIcon
        childController.title = title
        let navigation = BaseNavigationController.init(rootViewController: childController)
        addChildViewController(navigation)
    }
}
