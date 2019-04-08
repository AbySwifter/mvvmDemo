//
//  MJRefresh+Rx.swift
//  RxTripshow
//
//  Created by aby on 2018/9/13.
//  Copyright © 2018 aby. All rights reserved.
//

import RxSwift
import RxCocoa
import MJRefresh

// 对MJRefreshComponent增加Rx扩展
extension Reactive where Base: MJRefreshComponent {

    // 正在刷新的事件
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create { [weak control = self.base] observer in
            if let control = control {
                // 刷新的block定义为事件的发送
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }

    // 停止刷新
    var endRefresh: Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                // 结束刷新的事件触发
                refresh.endRefreshing()
            }
        }
    }

}
