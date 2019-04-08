//
//  CorrelationVideoCell.swift
//  RxTripshow
//
//  Created by aby on 2018/9/6.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

class CorrelationVideoCell: UITableViewCell {

    static let cellID: String = "CorrelationVideoCell"

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var likedCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        icon.image = icon.image?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = UIColor.hexInt(0x999999)
    }

}

extension CorrelationVideoCell {
    func setCell(model: VideoItem) {
        self.cover.kf.setImage(with: URL.init(string: model.Image))
        self.title.text = model.VideoName
        self.owner.text = model.Owner + " 发布/"
        self.likedCount.text = "\(model.LikeCount)"
    }
}
