//
//  UnitCase.swift
//  RxTripshow
//
//  Created by aby on 2018/8/27.
//  Copyright © 2018 aby. All rights reserved.
//  存储view和viewModel的对应关系

import Foundation

struct MVVMUnit {
    let viewType: MVVMView.Type
    let viewModelType: MVVMViewModel.Type
}

extension MVVMUnit: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = AnyClass
    init(arrayLiteral elements: MVVMUnit.ArrayLiteralElement...) {
        guard elements.count == 2 else { fatalError("单元初始化参数长度错误") }
        guard let viewType = elements[0] as? MVVMView.Type else { fatalError("单元初始化参数错误") }
        guard let viewModelType = elements[1] as? MVVMViewModel.Type else { fatalError("单元初始化参数类型错误") }
        self.viewType = viewType
        self.viewModelType = viewModelType
    }
}

// UnitCase
struct MVVMUnitCase: RawRepresentable {
    typealias RawValue = MVVMUnit

    let rawValue: MVVMUnit

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension MVVMUnitCase {
    static let discovery = MVVMUnitCase.init(rawValue: [DiscoveryViewController.self, DiscoveryViewModel.self])
    static let channel = MVVMUnitCase.init(rawValue: [ChannelViewController.self, ChannelViewModel.self])
    static let personal = MVVMUnitCase.init(rawValue: [PersonalCenterViewController.self, PersonalViewModel.self])
    static let signin = MVVMUnitCase.init(rawValue: [SignInViewController.self, SignViewModel.self])
    static let videoDetail = MVVMUnitCase.init(rawValue: [VideoDetailViewController.self, VideoDetailViewModel.self])
    static let channelDetail = MVVMUnitCase.init(rawValue: [ChannelDetailViewController.self, ChannelDetailViewModel.self])
}

// Binder
struct MVVMBinder {
    /// 根据标识符获取视图，会在背后做视图与视图模型的绑定
    ///
    /// - Parameter identifier: 标识符
    /// - Returns: 返回已经绑定好了的视图
    static func obtainBindedView(_ unitCase: MVVMUnitCase) -> MVVMView {
        let unit = unitCase.rawValue
        let viewType = unit.viewType
        let viewModelType = unit.viewModelType
        let view = viewType.init(viewModelType)
        return view
    }
}
