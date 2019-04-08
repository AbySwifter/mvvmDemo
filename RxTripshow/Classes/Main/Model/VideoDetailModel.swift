//
//  VideoDetailModel.swift
//  RxTripshow
//
//  Created by aby on 2018/9/5.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import HandyJSON

class VideoDetailModel: HandyJSON {
    var id: Int = -1
    var createTime: String = ""
    var description: String = ""
    var duration: Int = 0
    var image: String = ""
    var labels: Array<Labels> = []
    var likedCount: Int = 0
    var liked: Bool = false
    var owner: Owner?
    var url: String = ""
    var url2: String = ""
    var videoName: String = ""

    var durationString: String {
        return translateSecond(self.duration)
    }

    var ownerStr: String = ""

    var ownerName: String {
        guard let owner = owner else {
            return ownerStr
        }
        return owner.ownerName
    }

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper.exclude(property: &id)
        mapper.exclude(property: &ownerStr)

        mapper.specify(property: &createTime, name: "CreateTime")
        mapper.specify(property: &description, name: "Description")
        mapper.specify(property: &image, name: "Image")
        mapper.specify(property: &labels, name: "Labels")
        mapper.specify(property: &likedCount, name: "LikeCount")
        mapper.specify(property: &owner, name: "Owner")
        mapper.specify(property: &url, name: "URL")
        mapper.specify(property: &url2, name: "URL2")
        mapper.specify(property: &videoName, name: "VideoName")
        mapper.specify(property: &duration, name: "Duration")
        mapper.specify(property: &liked, name: "Liked") { (value) -> Bool in
            guard let likedNum = Int(value) else { return false }
            return likedNum == 1
        }
    }
}

extension VideoDetailModel {
    func setModel(item: VideoItem) {
        self.liked = item.Liked
        self.id = item.ID
        self.description = item.Description
        self.image = item.Image
        self.likedCount = item.LikeCount
        self.url = item.URL
        self.url2 = item.URL2
        self.videoName = item.VideoName
        self.duration = item.Duration
        self.ownerStr = item.Owner
    }
}

struct Labels: HandyJSON, TagItem {
    var id: Int = 0
    var label: String = ""

    var tagName: String {
        return self.label
    }

    mutating func mapping(mapper: HelpingMapper) {
        mapper.specify(property: &id, name: "ID")
        mapper.specify(property: &label, name: "Label")
    }
}

struct Owner: HandyJSON {
    var description: String  = ""
    var ownerID: Int  = 0
    var ownerName: String = ""
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.description <-- "Description"
        mapper <<<
            self.ownerID <-- "OwnerID"
        mapper <<<
            self.ownerName <-- "OwnerName"
    }

}
