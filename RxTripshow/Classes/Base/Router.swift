//
//  Router.swift
//  RxTripshow
//
//  Created by aby on 2018/8/27.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum RouterType {
    case push(MVVMUnitCase)
    case present(MVVMUnitCase)
    case root(MVVMUnitCase)
    case back
}

struct Router {
    let from: MVVMView
    init(from: MVVMView) {
        self.from = from
    }

    func route(_ type: RouterType, send: Driver<Any>? = nil) -> Driver<Any>? {
        switch type {
        case let .push(unitCase):
            let view = MVVMBinder.obtainBindedView(unitCase)
            view.receive = send
            from.navigationController?.pushViewController(view, animated: true)
            return view.provideCallBack()
        case let .present(unitCase):
            let view = MVVMBinder.obtainBindedView(unitCase)
            view.receive = send
            from.present(view, animated: true, completion: nil)
            return view.provideCallBack()
        case let .root(unitCase):
            let view = MVVMBinder.obtainBindedView(unitCase)
            view.receive = send
            UIApplication.shared.keyWindow?.rootViewController = view
            return view.provideCallBack()
        case .back:
            if from.presentingViewController != nil {
                from.presentingViewController?.dismiss(animated: true, completion: nil)
            } else {
                _ = from.navigationController?.popViewController(animated: true)
            }
            return nil
        }
    }
}

extension MVVMView {
    func route(_ type: RouterType, send: Driver<Any>? = nil) -> Driver<Any>? {
        return self.router.route(type, send: send)
    }
}
