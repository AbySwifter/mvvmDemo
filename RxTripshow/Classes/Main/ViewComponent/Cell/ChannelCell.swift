//
//  ChannelCell.swift
//  RxTripshow
//
//  Created by aby on 2018/8/23.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class ChannelCell: UITableViewCell {

    let coverImage: UIImageView = UIImageView.init(frame: CGRect.zero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.removeFromSuperview()
        self.addSubview(coverImage)
        coverImage.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
        }
        self.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setCell(model: ChannelModel) {
        guard let url = URL.init(string: model.image) else {
            return
        }
        coverImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "noImg"), options: nil, progressBlock: nil, completionHandler: nil)
    }
}
