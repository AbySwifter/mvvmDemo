//
//  BaseViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/21.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum ListRefreshStatus {
    case none
    case beingHeaderRefresh // 下拉刷新
    case endHeaderRefresh
    case beingFooterRefresh // 上拉加载
    case endFooterRefresh
    case noMoreData
}

enum PageRefreshStatus {
    case none // 没有动作
    case beginRefresh // 开始刷新
    case endRefresh // 刷新结束
}

// 拟抽象类，VIewModel的父类
class MVVMViewModel: NSObject, OutputProvider {
    var outputType: MVVMOutput.Type? { return nil }
    let input: MVVMInput

    required init(input: MVVMInput) {
        self.input = input
    }

    func vmWillBindView() {}

    lazy var bag = DisposeBag.init()

    // 可重写的类
    func provideOutput() -> MVVMOutput? {
        return self.outputType?.init(viewModel: self)
    }
}
