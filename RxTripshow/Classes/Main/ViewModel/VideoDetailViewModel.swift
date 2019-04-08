//
//  VideoDetailViewModel.swift
//  RxTripshow
//
//  Created by aby on 2018/9/4.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import BMPlayer

class VideoDetailViewModel: MVVMViewModel {
    override var outputType: MVVMOutput.Type? { return VideoDetailOutput.self }
    let videoInfo = BehaviorRelay<VideoDetailModel>.init(value: VideoDetailModel.init())
    let headerUpdate = PublishSubject<Void>.init()
    let videoCorrlation = PublishRelay<Array<VideoItem>>.init()
    override func vmWillBindView() {
        let input = self.input as! VideoDetailInput
        input.videoInfo.map { (item) -> VideoDetailModel in
            let model = VideoDetailModel.init()
            model.setModel(item: item)
            return model
        }.drive(videoInfo).disposed(by: bag)
        input.requestCommond.asObservable().subscribe { (_) in
            self.getVideoDetail()
        }.disposed(by: bag)
        correlationVideos() // 绑定相关视屏推荐
    }

    func titleDrive() -> Driver<String> {
        return videoInfo.asObservable().map({ (model) -> String in
            return model.videoName
        }).asDriver(onErrorJustReturn: "")
    }

    func subTitleDrive() -> Driver<NSAttributedString> {
        let drive = videoInfo.asObservable().map { (model) -> NSAttributedString in
            let attr = NSMutableAttributedString.init(string: model.ownerName)
            attr.addAttribute(.underlineStyle, value: 1, range: NSRange.init(location: 0, length: attr.length))
            attr.append(NSAttributedString.init(string: "发布 / \(model.durationString)"))
            return attr as NSAttributedString
        }.asDriver(onErrorJustReturn: NSAttributedString.init(string: ""))
        return drive
    }

    func labelsDriver() -> Driver<Array<Labels>> {
        let driver = videoInfo.asObservable().map { (model) -> Array<Labels> in
            return model.labels
        }.asDriver(onErrorJustReturn: [])
        return driver
    }

    func updateCorrlationDriver() -> Driver<Array<VideoItem>> {
        let driver = videoCorrlation.asDriver(onErrorJustReturn: [])
        return driver
    }

    func descriptionDriver() -> Driver<NSAttributedString> {
        let driver = videoInfo.asObservable().map { (model) -> NSAttributedString in
            let data = model.description.data(using: .unicode, allowLossyConversion: true)
            let attrStr = try NSMutableAttributedString.init(data: data!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            let paragraphStyle = NSMutableParagraphStyle.init()
            paragraphStyle.alignment = .center
            attrStr.addAttributes([
                NSAttributedStringKey.foregroundColor: UIColor.hexInt(0xb8b8b8),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0),
                NSAttributedStringKey.paragraphStyle: paragraphStyle
                ], range: NSRange.init(location: 0, length: attrStr.length))
            return attrStr as NSAttributedString
            }.asDriver(onErrorJustReturn: NSAttributedString.init(string: ""))
        return driver
    }

    // 获取视屏详情
    func getVideoDetail() {
        let item = videoInfo.value
        guard item.id != -1 else { return }
        Network.provider.rx.request(Api.videoDetail(id: item.id, session: UserShared.shared.sign.userSession))
            .asObservable()
            .mapModel(BaseResponseModel<VideoDetailModel>.self)
            .subscribe { (event) in
                switch event {
                case .next(let result):
                    guard let model = result.data else { return }
                    model.id = item.id
                    self.videoInfo.accept(model) // 更新数据
                    self.headerUpdate.onNext(())
                case .error(let error):
                    DTLog(error)
                // FIXME:发出网络错误的提示
                case .completed:
                    break
                }
            }.disposed(by: bag)
    }

    // 获取相关视频
    func getCorrelationVideos(ids: [Int]) {
        let queue = DispatchQueue.init(label: "getCorrelationVideo")
        let group = DispatchGroup.init()
        var result = [VideoItem]()
        for id in ids {
            let item = DispatchWorkItem.init(block: {
                group.enter()
                // 请求相关数据
                Network.provider.rx.request(Api.getVideoList(label: id, order: "like", session: UserShared.shared.sign.userSession, page: 0)).asObservable()
                    .mapModel(BaseResponseArrModel<VideoItem>.self)
                    .subscribe({ (event) in
                        switch event {
                        case let .next(element):
                            result.append(contentsOf: element.data ?? [])
                        case let .error(error):
                            DTLog(error)
                        case .completed:
                            group.leave()
                        }
                    }).disposed(by: self.bag)
            })
            queue.async(group: group, execute: item )
        }
        group.notify(queue: queue) {
            // 执行结束
            let arr = result.filter({ (item) -> Bool in
                return item.ID != self.videoInfo.value.id
            })
            self.videoCorrlation.accept(arr)
        }
    }

    func correlationVideos() {
        videoInfo.asObservable().filter({ (model) -> Bool in
            return model.labels.count != 0
        }).map { (model) -> [Int] in
                let arr = model.labels
                let ids = arr.filter({ (item) -> Bool in
                    return item.label != "精彩推荐"
                }).map({ (label) -> Int in
                    return label.id
                })
                return ids
            }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { (ids) in
                self.getCorrelationVideos(ids: ids)
            }).disposed(by: bag)
    }
    func playerResource() -> Driver<BMPlayerResource?> {
        return videoInfo.distinctUntilChanged({ (old, new) -> Bool in
            return old.id != new.id
        }).map({ (model) -> BMPlayerResource? in

            let res0 = BMPlayerResourceDefinition.init(url: URL.init(string: model.url)!, definition: "标清")
            let res2 = BMPlayerResourceDefinition.init(url: URL.init(string: model.url2)!, definition: "高清")
            let asset = BMPlayerResource.init(name: model.videoName, definitions: [res0, res2], cover: URL.init(string: model.image)!, subtitles: nil)
            return asset
        }).asDriver(onErrorJustReturn: nil)
    }
}

struct VideoDetailOutput: MVVMOutput {
    init(viewModel: MVVMViewModel) {
        let vm = viewModel as! VideoDetailViewModel
        titleDriver = vm.titleDrive()
        subTitleDriver = vm.subTitleDrive()
        labelsDriver = vm.labelsDriver()
        updateTabheader = vm.headerUpdate
        updateCorrlation = vm.updateCorrlationDriver()
        despritionDriver = vm.descriptionDriver()
        playerResource = vm.playerResource()
    }
    let refreshStatus = BehaviorRelay<PageRefreshStatus>.init(value: .none)
    let titleDriver: Driver<String>
    let subTitleDriver: Driver<NSAttributedString>
    let labelsDriver: Driver<Array<Labels>>
    let despritionDriver: Driver<NSAttributedString>
    let updateTabheader: PublishSubject<Void>
    let updateCorrlation: Driver<Array<VideoItem>>
    let playerResource: Driver<BMPlayerResource?>
}
