//
//  ChannelViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/23.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ChannelViewModel: MVVMViewModel {
    // Observable 事件源
    private var listObservable = BehaviorRelay<[ChannelModel]>.init(value: [])
    private var nameSubject = BehaviorSubject<String>.init(value: "")

    var getInput: ChannelViewController.ChannelInput? {
        return self.input as? ChannelViewController.ChannelInput
    }

    override func provideOutput() -> MVVMOutput? {
        let output = ChannelOutPut.init(viewModel: self)
        self.getInput?.requestCommond.subscribe(onNext: { (_) in
            self.getData(output: output)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: bag)
        return output
    }
}

extension ChannelViewModel {

    struct ChannelOutPut: MVVMOutput {
        init(viewModel: MVVMViewModel) {
            let viewModel = viewModel as! ChannelViewModel
            self.listData = viewModel.listObservable.asDriver()
        }
        let listData: Driver<[ChannelModel]>
        let refreshStatus = BehaviorRelay<ListRefreshStatus>.init(value: .none)
    }

    func getData(output: ChannelOutPut) {
        Network.provider.rx.request(Api.getChannelList(page: 0)).asObservable()
        .mapModel(BaseResponseArrModel<ChannelModel>.self)
            .subscribe { (event) in
                switch event {
                case .next(let baseModel):
                    if let datas = baseModel.data {
                        self.listObservable.accept(datas)
                    }
                case .error(let error):
                    DTLog(error.localizedDescription)
                case .completed:
                    output.refreshStatus.accept(ListRefreshStatus.endHeaderRefresh)
                }
        }.disposed(by: bag)
    }
}
