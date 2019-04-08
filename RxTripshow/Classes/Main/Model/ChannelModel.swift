//
//  ChannelModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/23.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import HandyJSON

struct ChannelModel: HandyJSON {
    var ID: Int = 0
    var image: String = ""
    var label: String = "" // 标签

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &image, name: "Image")
        mapper.specify(property: &label, name: "Label")
    }
}
