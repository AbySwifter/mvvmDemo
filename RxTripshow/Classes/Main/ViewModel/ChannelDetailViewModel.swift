//
//  ChannelDetailViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/9/17.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

/// 频道详情输出结构体
/// - 用于MVVM的绑定
struct ChannelDetailOutput: MVVMOutput {
    init(viewModel: MVVMViewModel) {
        // swiftlint:disable force_cast
        let vm = viewModel as! ChannelDetailViewModel
        videoListDriver = vm.createListDriver() // 创建列表的数据源
    }
    let videoListDriver: Driver<Array<VideoItem>>
}

class ChannelDetailViewModel: MVVMViewModel {
    var channelDetail: BehaviorRelay = BehaviorRelay<ChannelDetailModel>.init(value: ChannelDetailModel.init()) // 频道详情数据存储
    override var outputType: MVVMOutput.Type { return ChannelDetailOutput.self }
    override func vmWillBindView() {
        let input = self.input as! ChannelDetailInput
        input.channelInfo.drive(onNext: { (model) in
            self.getData(model.ID)
        }, onCompleted: nil, onDisposed: nil).disposed(by: bag)
    }
    /**
     获取频道列表的方法
     - Parameter label: 请求标签的id
     - Parameter order: 排序方法
     
     - Returns: 没有返回值
     */
    func getData(_ label: Int, order: String = "time") {
        // 这里需要判断传回来的值，确认是需要用数组来处理
        Network.provider.rx.request(Api.getVideoList(label: label, order: "hot", session: UserShared.shared.sign.userSession, page: 0))
            .asObservable()
            .mapModel(BaseResponseModel<ChannelDetailModel>.self)
            .subscribe { (event) in
                switch event {
                case .next(let model):
                    let detailModel = model.data ?? ChannelDetailModel.init()
                    self.channelDetail.accept(detailModel)
                case .error(let error):
                    print(error)
                case .completed:
                    break
                }
        }.disposed(by: bag)
    }
    func createListDriver() -> Driver<Array<VideoItem>> {
        let driver = self.channelDetail.asDriver().map { (model) -> Array<VideoItem> in
            return model.videoList
        }
        return driver
    }
}
