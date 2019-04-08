//
//  NetWorkManager.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import Moya
import RxSwift

struct Network {
    static let provider = MoyaProvider<Api>.init()
//    static func request(api: Api) {
//        Network.provider.rx.request(api).catchError { (error) -> PrimitiveSequence<SingleTrait, Response> in
//
//        }
//    }
}
