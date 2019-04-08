//
//  PersionCell.swift
//  RxTripshow
//
//  Created by aby on 2018/8/24.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import SnapKit

class PersonCell: UITableViewCell {

    let icon: UIImageView = UIImageView.init(frame: CGRect.zero)
    let title: UILabel = UILabel.init(frame: CGRect.zero)
    let rightIcon: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "right_more"))
    let sepator: UIView = UIView.init()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.removeFromSuperview() // 移除本身的ContentView
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        makeConstraint()
        makeSuface()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func makeConstraint() {
        self.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.width.height.equalTo(W750(45))
        }
        self.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(15)
            make.centerY.equalTo(icon.snp.centerY)
        }
        self.addSubview(rightIcon)
        rightIcon.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-15)
            make.centerY.equalTo(self)
            make.height.equalTo(W750(45))
            make.width.equalTo(W750(24))
        }
        self.addSubview(sepator)
        sepator.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.left.equalTo(self).offset(15)
            make.right.equalTo(self).offset(-15)
            make.height.equalTo(1)
        }
    }

    func makeSuface() {
        title.textColor = S_textWhite
        title.font = UIFont.systemFont(ofSize: 14)
        sepator.backgroundColor = UIColor.hexInt(0x333333)
    }
}
