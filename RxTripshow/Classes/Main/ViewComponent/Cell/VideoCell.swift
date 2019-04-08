//
//  VideoCell.swift
//  RxTripshow
//
//  Created by aby on 2018/8/21.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class VideoCell: UITableViewCell {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var likedBtn: UIButton!

    private(set) var disposeBag = DisposeBag()

    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.likedBtn.setImage(#imageLiteral(resourceName: "thumbs-up-selected"), for: UIControlState.disabled)
        self.likedBtn.setImage(#imageLiteral(resourceName: "thumbs-up-no-select"), for: UIControlState.normal)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag.init()
    }

    func setCell(model: VideoItem, for indexPath: IndexPath) {
        let url = URL.init(string: model.Image)
        self.coverImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "noImg"), options: nil, progressBlock: nil) { (image, error, _, _) in
            if error != nil {
                self.coverImage.image = #imageLiteral(resourceName: "failImg")
            }
        }
        self.author.text = "\(model.Owner) 发布 /\(translateSecond(model.Duration))"
        self.title.text = model.VideoName
        self.likeCount.text = "\(model.LikeCount)"
        self.likedBtn.isEnabled = !model.Liked
    }
}
