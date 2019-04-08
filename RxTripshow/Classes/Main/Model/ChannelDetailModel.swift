//
//  ChannelDetailModel.swift
//  RxTripshow
//
//  Created by aby on 2018/9/25.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import HandyJSON

class ChannelDetailModel: HandyJSON {
    required init() {}
    var description: String = ""
    var image: String = ""
    var name: String = ""
    var slug: String = ""
    var videoList: Array<VideoItem> = []
    
    func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &description, name: "Description")
        mapper.specify(property: &image, name: "Image")
        mapper.specify(property: &name, name: "Name")
        mapper.specify(property: &slug, name: "Slug")
        mapper.specify(property: &videoList, name: "VideoList")
    }
}
