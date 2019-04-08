//
//  InputOutputPro.swift
//  RxTripshow
//
//  Created by aby on 2018/8/27.
//  Copyright © 2018 aby. All rights reserved.
//
//  Provider（提供者）是针对Input跟Output的构建而设计的，意为Input与Output的提供者。每个提供者里具有一个元类类型的属性以及一个提供方法，而在分类中，提供方法已经帮我们去实现了。所以在实现提供者协议的时候，我们只需提供相应的Input或Output类型即可。
//

import Foundation

// Input & Output Protocol

protocol MVVMInput {
    init(view: MVVMView)
}

protocol MVVMOutput {
    init(viewModel: MVVMViewModel)
}

// 提供Input provider
// View To ViewModel
protocol InputProvider {
    var inputType: MVVMInput.Type? { get }
    func provideInput() -> MVVMInput?
}

extension InputProvider where Self: MVVMView {
    // 默认的Input提供方法
    func provideInput() -> MVVMInput? {
        return self.inputType?.init(view: self)
    }
}

// 提供Output provider
// ViewModel To View
protocol OutputProvider {
    var outputType: MVVMOutput.Type? { get }
    func provideOutput() -> MVVMOutput?
}

extension OutputProvider where Self: MVVMViewModel {
    func provideOutput() -> MVVMOutput? {
        return self.outputType?.init(viewModel: self)
    }
}
