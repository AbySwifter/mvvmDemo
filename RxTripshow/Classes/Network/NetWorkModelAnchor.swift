//
//  File.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import HandyJSON

struct BaseResponseModel<T: HandyJSON>: HandyJSON {
    var err: Int = -1
    var msg: String = ""
    var data: T?
}

struct BaseResponseArrModel<T: HandyJSON>: HandyJSON {
    var err: Int = -1
    var msg: String = ""
    var data: [T]?
}

// MARK: Json -> Observable<Model>
extension ObservableType where E == Response {
    public func mapModel<T: HandyJSON>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(response.mapModel(T.self))
        }
    }
}

// MARK: Json -> Model
extension Response {
    func mapModel<T: HandyJSON>(_ type: T.Type) -> T {
        let jsonString = String.init(data: self.data, encoding: .utf8)
        return JSONDeserializer<T>.deserializeFrom(json: jsonString)!
    }
}
