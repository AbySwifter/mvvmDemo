//
//  AppDelegate.swift
//  RxTripshow
//
//  Created by aby on 2018/8/16.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let rootViewController = BaseTabBarViewController()
        rootViewController.add(childController: MVVMBinder.obtainBindedView(.discovery), title: "发现", icon: #imageLiteral(resourceName: "discover_tab"))
        rootViewController.add(childController: MVVMBinder.obtainBindedView(.channel), title: "频道", icon: #imageLiteral(resourceName: "channer_tab"))
        rootViewController.add(childController: MVVMBinder.obtainBindedView(.personal), title: "我的", icon: #imageLiteral(resourceName: "mine_tab"))
        self.window?.rootViewController = rootViewController

        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
