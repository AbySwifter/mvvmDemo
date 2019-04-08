//
//  DiscoveryModel.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import Foundation
import HandyJSON
import RxDataSources

// swiftlint:disable identifier_name
struct VideoItem: HandyJSON {
    var CreateTime: String = ""
    var Description: String = ""
    var Duration: Int = 0
    var ID: Int = 0
    var Image: String = ""
    var LikeCount: Int = 0
    var Liked: Bool = false
    var Owner: String = ""
    var URL: String = ""
    var URL2: String = ""
    var VideoName: String = ""

    var durationString: String {
        return translateSecond(self.Duration)
    }

    mutating func mapping(mapper: HelpingMapper) {

    }
}

struct BannerItem: HandyJSON {
    var Image: String = ""
    var LabelID: Int = 0
    var LabelName: String = ""
    var Target: String = ""
}

struct VideoList: HandyJSON {
    var banners: Array<BannerItem> = []
    var likeEnable: Int = 0
    var list: Array<VideoItem> = []
    mutating func mapping(mapper: HelpingMapper) {
//        mapper <<<
//            self.banners <-- "banner"
        mapper.specify(property: &banners, name: "banner")

    }
}

struct DiscoveryTabData {
    var items: [VideoItem]
}

extension DiscoveryTabData: SectionModelType {
    typealias Item = VideoItem
    init(original: DiscoveryTabData, items: [DiscoveryTabData.Item]) {
        self = original
    }
}
