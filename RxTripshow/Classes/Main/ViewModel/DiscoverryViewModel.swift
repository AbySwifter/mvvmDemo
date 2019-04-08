//
//  DiscoverryViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/21.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DiscoveryViewModel: MVVMViewModel {

    var getInput: DiscoveryInput {
        return self.input as! DiscoveryInput
    }
    // Observable 产生事件
    var dataSourceObservable = BehaviorRelay<VideoList?>.init(value: nil)
    var videoListObservable = BehaviorRelay<[DiscoveryTabData]>.init(value: [])
    var enableLikedObservable = BehaviorRelay<Bool>.init(value: false)
    var routerObservable = PublishSubject<MVVMUnitCase?>.init()

    var page: Int = 1

    override var outputType: MVVMOutput.Type? { return DiscoveryOutput.self }

    override func provideOutput() -> MVVMOutput? {
        let output = DiscoveryOutput.init(viewModel: self)
        self.getInput.requestCommond.asObservable().subscribe(onNext: { (isReload) in
            self.page = isReload ? 1 : self.page + 1
            self.getData(output: output, isReload: isReload)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.bag)
        self.getInput.cellLikeBtnTap.asObserver().subscribe(onNext: { (indexPath) in
            switch UserShared.shared.loginStatus {
            case .loginIn:
                // 点赞动作
                self.liked(indexPath)
            case .loginOut:
                self.routerObservable.onNext(MVVMUnitCase.signin)
            }
        }).disposed(by: self.bag)
        return output
    }

}

extension DiscoveryViewModel {
    // 获取网络数据的事件
    func getData(output: DiscoveryOutput, isReload: Bool) {
        Network.provider.rx.request(Api.getHomeVideoList(page: self.page, session: UserShared.shared.sign.userSession))
            .asObservable()
            .mapModel(BaseResponseModel<VideoList>.self)
            .subscribe({ (event) in
                switch event {
                case let .next(model):
                    if let data = model.data {
                        self.dataSourceObservable.accept(data)
                        let list = DiscoveryTabData.init(items: data.list)
                        var arr = self.videoListObservable.value
                        arr = isReload ? [list] : arr + [list]
                        self.videoListObservable.accept(arr)
                    }
                    self.enableLikedObservable.accept(model.data?.likeEnable == 1)
                case let .error(error):
                    DTLog(error.localizedDescription)
                case .completed:
                    output.refreshStatus.accept(isReload ? .endHeaderRefresh : .endFooterRefresh)
                }
            }).disposed(by: self.bag)
    }
    // 点赞方法
    func liked(_ indexPath: IndexPath) {
        guard let session = UserShared.shared.sign.userSession else { return }
        var videoList = videoListObservable.value
        let section = videoList[indexPath.section]
        let item = section.items[indexPath.row]
        Network.provider.rx.request(Api.like(videoID: item.ID, session: session))
            .asObservable()
            .mapJSON()
            .subscribe { (event) in
                switch event {
                case .next(let data):
                    DTLog(data)
                    videoList[indexPath.section].items[indexPath.row].Liked = true
                    videoList[indexPath.section].items[indexPath.row].LikeCount += 1
                    self.videoListObservable.accept(videoList)
                case .error(let error):
                    DTLog(error)
                case .completed:
                    DTLog("网络加载完成")
                }
        }.disposed(by: self.bag)
    }
}

struct DiscoveryOutput: MVVMOutput {
    init(viewModel: MVVMViewModel) {
        let viewModel = viewModel as! DiscoveryViewModel
        self.enableLiked = viewModel.enableLikedObservable.asDriver().asDriver(onErrorJustReturn: false)
        self.data = viewModel.dataSourceObservable.asDriver().asDriver(onErrorJustReturn: nil)
        self.videoList = viewModel.videoListObservable.asDriver().asDriver(onErrorJustReturn: [])
        self.routeAction = viewModel.routerObservable.asDriver(onErrorJustReturn: nil)
    }
    // 外界通过该属性告诉ViewModel加载数据
    let requestCommond = PublishSubject<Bool>.init()
    // tableviewBanner的数据
    let enableLiked: Driver<Bool>
    let data: Driver<VideoList?>
    let videoList: Driver<[DiscoveryTabData]>
    // tableview的刷新状态
    let refreshStatus = BehaviorRelay<ListRefreshStatus>.init(value: .none)
    // 跳转页面的命令
    let routeAction: Driver<MVVMUnitCase?>
}
