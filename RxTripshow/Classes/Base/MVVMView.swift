//
//  MVVMView.swift
//  RxTripshow
//
//  Created by aby on 2018/8/17.
//  Copyright © 2018 aby. All rights reserved.
//
// 在MVVMView的viewDidLoad()方法中，我们进行MVVMView和MVVMViewModel的关联，如果MVVMView和MVVMViewModel没有提供Input和Output，则表明此时View和ViewModel层没有通信，所以也就不会调用rxDrive方法了。

import UIKit
import RxSwift
import RxCocoa

class MVVMView: UIViewController, InputProvider {
    typealias DriverUIResult = (Bool, String)
    private let viewModelType: MVVMViewModel.Type?
    private(set) var router: Router!
    var viewModel: MVVMViewModel?
    var inputType: MVVMInput.Type? { return nil }
    var receive: Driver<Any>?

    required init(_ viewModelType: MVVMViewModel.Type?) {
        self.viewModelType = viewModelType
        super.init(nibName: nil, bundle: nil)
        self.router = Router(from: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewModelType = self.viewModelType, let input = self.provideInput() {
            self.viewModel = viewModelType.init(input: input)
            self.viewModel?.vmWillBindView() // ViewModel用来处理input的
            rxBind(viewInput: self.viewModel!.input) // View处理Input （部分事件无法在init方法中处理）
            if let output = self.viewModel!.provideOutput() {
                rxDrive(viewModelOutput: output) // View处理output
            }
        }
    }

    /// 这个方法就是用于将从ViewModel层出来的事件数据流驱动整个页面的显示.
    /// 我们可以通过传进来的参数Ouput驱动视图的刷新显示、进行页面的跳转。
    /// 这个方法也是ViewModel层向View层传递信息的唯一出口。
    ///
    /// - Parameter viewModelOutput: viewModel的Output流
    func rxDrive(viewModelOutput: MVVMOutput) { assertionFailure("必须重写该方法") }

    // 可重写可不重写
    func rxBind(viewInput: MVVMInput) {}
    // 此方法是用于页面跳转中的反向数据传递，即将数据从本页面传到上一个页面，
    func provideCallBack() -> Driver<Any>? { return nil }
    // RX回收属性
    let disposeBag = DisposeBag.init()
}
