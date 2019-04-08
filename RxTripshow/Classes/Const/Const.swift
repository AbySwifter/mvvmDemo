//
//  Const.swift
//  RxTripshow
//
//  Created by aby on 2018/8/22.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation

@_exported import AbyToolCollection
//@_exported import SnapKit

func translateSecond(_ seconds: Int) -> String {
    let sec = seconds % 60
    let min = seconds / 60
    if min == 0 {
        return "\(sec)\""
    }
    return "\(min)'\(sec)\""
}
