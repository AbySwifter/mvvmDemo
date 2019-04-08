//
//  VideoDetailViewController.swift
//  RxTripshow
//
//  Created by aby on 2018/9/4.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import BMPlayer

struct VideoDetailInput: MVVMInput {
    init(view: MVVMView) {
        videoInfo = (view.receive?.asDriver().map({ (item) -> VideoItem in
            return item as! VideoItem
        }))!
    }
    let videoInfo: Driver<VideoItem>
    let requestCommond: PublishSubject<Void> = PublishSubject<Void>.init()
}

class VideoDetailViewController: MVVMView, UITableViewDelegate {

    lazy var playerView: BMPlayer = {
        BMPlayerConf.allowLog = false
        BMPlayerConf.shouldAutoPlay = false
        BMPlayerConf.topBarShowInCase = BMPlayerTopBarShowCase.always
        let player = BMPlayer.init()
        view.backgroundColor = UIColor.black
        player.backBlock = { isFullScreen in
            if isFullScreen { return }
            player.pause(allowAutoPlay: true)
           _ = self.router.route(RouterType.back)
        }
        player.delegate = self
        return player
    }() // 播放器的占位视图

    lazy var tableview: UITableView = {
        let tab = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        tab.rx.setDelegate(self).disposed(by: self.disposeBag)
        tab.separatorStyle = .none
        tab.register(UINib.init(nibName: "CorrelationVideoCell", bundle: nil), forCellReuseIdentifier: CorrelationVideoCell.cellID)
        return tab
    }()

    lazy var bottomBar: UIView = {
        let bar = UIView.init()
        bar.backgroundColor = UIColor.hexInt(0xf6f6f6)
        return bar
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    lazy var owners: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.textColor = UIColor.hexInt(0xb8b8b8)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        return label
    }()

    lazy var tagsView: AlTagView<Labels> = {
        let tags = AlTagView<Labels>.init(tags: [], maxRowW: view.width - 60, rowH: W375(40), marginX: 10, showAddBtn: false, showClose: false)
        return tags
    }()
    // subTitle是一个WebView的视图
    lazy var descriptionLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.hexInt(0x333333)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = ""
        label.textAlignment = .center
        return label
    }()

    // MARK: MVVM Method
    override var inputType: MVVMInput.Type? { return VideoDetailInput.self }

    // 绑定output
    override func rxDrive(viewModelOutput: MVVMOutput) {
        let output = viewModelOutput as! VideoDetailOutput
        output.titleDriver.drive(self.titleLabel.rx.text).disposed(by: disposeBag)
        output.subTitleDriver.drive(self.owners.rx.attributedText).disposed(by: disposeBag)
        output.labelsDriver.drive(onNext: { (labels) in
            self.tagsView.tags = labels
        }).disposed(by: disposeBag)
        output.despritionDriver.drive(self.descriptionLabel.rx.attributedText).disposed(by: disposeBag)
        output.updateTabheader.subscribe { (_) in
            self.updateHeaderView()
        }.disposed(by: disposeBag)
        output.updateCorrlation.drive(tableview.rx.items(cellIdentifier: CorrelationVideoCell.cellID, cellType: CorrelationVideoCell.self)) { (_, item, cell) in
            cell.setCell(model: item)
        }.disposed(by: disposeBag)
        output.playerResource.drive(onNext: { (res) in
            guard let resource = res else { return }
            self.playerView.setVideo(resource: resource)
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableview.tableHeaderView = makeTabHeadView()
        makeConstraints() // 添加视图
        (self.viewModel?.input as? VideoDetailInput)?.requestCommond.onNext(())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addTopBorder(originView: self.bottomBar) // 给bottom
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
//        self.setNavigationBarTranslucent()
        self.setNavigationBar(hide: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        self.setThemeNavigationBar(theme: S_themeDark)
        self.setNavigationBar(hide: false)
    }
}

extension VideoDetailViewController {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: view.width, height: W375(50)))
        sectionHeader.backgroundColor = UIColor.hexInt(0xf5f5f5)
        let sectionTitle = UILabel.init()
        sectionTitle.text = "相关视频"
        sectionTitle.font = UIFont.systemFont(ofSize: 14)
        sectionTitle.textColor = UIColor.hexInt(0xb8b8b8)
        sectionHeader.addSubview(sectionTitle)
        sectionTitle.snp.makeConstraints { (make) in
            make.center.equalTo(sectionHeader)
        }
        let boaderl = UIView.init()
        boaderl.backgroundColor = UIColor.hexInt(0xe8e8e8)
        sectionHeader.addSubview(boaderl)
        boaderl.snp.makeConstraints { (make) in
            make.centerY.equalTo(sectionHeader)
            make.height.equalTo(2 / UIScreen.main.scale)
            make.width.equalTo(W375(50))
            make.right.equalTo(sectionTitle.snp.left).offset(10)
        }
        let boaderR = UIView.init()
        boaderR.backgroundColor = UIColor.hexInt(0xe8e8e8)
        sectionHeader.addSubview(boaderR)
        boaderR.snp.makeConstraints { (make) in
            make.centerY.equalTo(sectionHeader)
            make.height.equalTo(2 / UIScreen.main.scale)
            make.width.equalTo(W375(50))
            make.left.equalTo(sectionTitle.snp.right).offset(10)
        }
        return sectionHeader
    }
}

extension VideoDetailViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return W375(50)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return W375(100)
    }
}

extension VideoDetailViewController {

    func makeTabHeadView() -> UIView {
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: view.width, height: 60))
        headView.addSubview(titleLabel)
        headView.addSubview(owners)
        headView.addSubview(tagsView)
        headView.addSubview(descriptionLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headView).offset(40)
            make.width.equalTo(view.width - 60)
            make.centerX.equalTo(headView)
        }
        owners.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.width.equalTo(view.width - 60)
            make.centerX.equalTo(headView)
        }
        tagsView.snp.makeConstraints { (make) in
            make.top.equalTo(owners.snp.bottom).offset(15)
            make.centerX.equalTo(headView)
            make.width.equalTo(tagsView.maxRowWidth)
            make.height.equalTo(tagsView.totalHeight)
        }
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tagsView.snp.bottom).offset(20)
            make.centerX.equalTo(headView)
            make.width.equalTo(view.width - 60)
        }
        titleLabel.sizeToFit()
        owners.sizeToFit()
        descriptionLabel.sizeToFit()
        let height = 100 + titleLabel.height + owners.height + tagsView.totalHeight + descriptionLabel.height
        headView.frame = CGRect.init(x: 0, y: 0, width: view.width, height: height)
        return headView
    }

    func updateHeaderView() {
        guard let headView = tableview.tableHeaderView else {return}
        titleLabel.sizeToFit()
        owners.sizeToFit()
        descriptionLabel.sizeToFit()
        let height = 100 + titleLabel.height + owners.height + tagsView.totalHeight + descriptionLabel.height
        headView.frame = CGRect.init(x: 0, y: 0, width: view.width, height: height)
        tableview.tableHeaderView = headView
    }

    func makeConstraints() {
        view.addSubview(playerView)
        view.addSubview(tableview)
        view.addSubview(bottomBar)
        playerView.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(view)
            make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
        }

        tableview.snp.makeConstraints { (make) in
            make.top.equalTo(playerView.snp.bottom)
            make.bottom.equalTo(bottomBar.snp.top)
            make.left.right.equalTo(view)
        }

        bottomBar.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(view)
            make.height.equalTo(W375(48))
        }
    }

    private func addTopBorder(originView: UIView) {
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint.init(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint.init(x: originView.width, y: 0))
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.strokeColor = UIColor.hexInt(0xcccccc).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = 2 / UIScreen.main.scale
        originView.layer.addSublayer(shapeLayer) // 添加上边界线
    }
}

extension VideoDetailViewController: BMPlayerDelegate {
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {

    }

    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {

    }

    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {

    }

    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {

    }

    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        if isFullscreen {
            self.tableview.isHidden = true
            playerView.snp.remakeConstraints { (make) in
                make.top.bottom.left.right.equalTo(self.view)
            }
        } else {
            playerView.snp.remakeConstraints { (make) in
                make.top.right.left.equalTo(view)
                make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0)
            }
            self.tableview.isHidden = false
        }
    }
}
