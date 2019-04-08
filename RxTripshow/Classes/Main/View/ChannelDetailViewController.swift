//
// Created by aby on 2018/9/17.
// Copyright (c) 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct ChannelDetailInput: MVVMInput {
    init(view: MVVMView) {
        let view = view as! ChannelDetailViewController
        channelInfo = view.receive?.asDriver().map({ (model) -> ChannelModel in
            return model as! ChannelModel
        }) ?? Driver.just(ChannelModel()).asDriver()
    }
    // 当前频道信息
    let channelInfo: Driver<ChannelModel>
}

class ChannelDetailViewController: MVVMView {
    lazy var tabView: UITableView = {
        let tab = UITableView.init(frame: CGRect.zero)
        tab.backgroundColor = UIColor.white
        tab.rx.setDataSource(self).disposed(by: disposeBag)
        tab.rx.setDelegate(self).disposed(by: disposeBag)
        return tab
    }()

    lazy var hotTableView: UITableView  = {
        let hot = UITableView.init(frame: CGRect.init(x: view.width, y: 0, width: view.width, height: view.height - 44))
        hot.backgroundColor = UIColor.green
        hot.rx.setDelegate(self).disposed(by: disposeBag)
        return hot
    }()

    lazy var latestTab: UITableView = {
        let latest = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: view.width, height: view.height - 44))
        latest.backgroundColor = UIColor.blue
        latest.rx.setDelegate(self).disposed(by: disposeBag)
        return latest
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    lazy var contentScrollView: UIScrollView = {
        let content = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: view.width, height: view.height - 44))
        content.contentSize = CGSize.init(width: view.width * 2, height: view.height - 44)
        content.isPagingEnabled = true
        content.showsHorizontalScrollIndicator = false
        content.showsVerticalScrollIndicator = false
        content.isDirectionalLockEnabled = true
        content.backgroundColor = UIColor.gray
        content.addSubview(latestTab)
        content.addSubview(hotTableView)
        return content
    }()

    // MARK: - 标记属性
    var mainScrollEnabled = false
    var subScrollEnabled = false
    var currentPanY: CGFloat = 0

    var maxOffsetY: CGFloat {
        return 104
    }

    var currentpage: Int {
        let page = contentScrollView.contentOffset.x/view.width
        return Int(page)
    }

    override var inputType: MVVMInput.Type { return ChannelDetailInput.self }

    // MARK: - 生命周期函数
    override func viewDidLoad() {
        super.viewDidLoad()
        makeHeadView() // 创建headView
        makeContraints()
        makeSurface()
        scrollSetting() // 设置滚动的动画
    }

    override func rxDrive(viewModelOutput: MVVMOutput) {

    }
}

extension ChannelDetailViewController {
    func makeHeadView() {
        let headView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: view.width, height: 60)) // 根据文本字符去转化高度
        headView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (maker) in
            maker.top.left.bottom.right.equalTo(headView)
        }
        tabView.tableHeaderView = headView
    }
    // 设置约束
    func makeContraints() {
        view.addSubview(tabView)
        tabView.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(view)
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    func makeSurface() {

    }

    func scrollSetting() {
        let pan = UIPanGestureRecognizer.init()
        pan.delegate = self
        pan.rx.event.asDriver().drive(onNext: { (gester) in
            self.panGestureRecognizerAction(recognizer: gester)
        }).disposed(by: disposeBag)
        tabView.addGestureRecognizer(pan)
    }
}

extension ChannelDetailViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if scrollView == tabView {
            if offset.y >= self.maxOffsetY {
                latestTab.isScrollEnabled = true
                hotTableView.isScrollEnabled = true
                tabView.isScrollEnabled = false
                subScrollEnabled = true
                mainScrollEnabled = false
            }
        } else {
            if offset.y <= 0 {
                latestTab.isScrollEnabled = false
                hotTableView.isScrollEnabled = false
                tabView.isScrollEnabled = true
                subScrollEnabled = false
                mainScrollEnabled = true
            }
        }
    }
}

extension ChannelDetailViewController: UITableViewDelegate, UITableViewDataSource {

    // DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.contentView.removeFromSuperview()
        cell.addSubview(self.contentScrollView)
        cell.backgroundColor = UIColor.red
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.height - 44
    }

    // delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tabView {
            let sectionHead = UIView.init(frame: CGRect.zero)
            sectionHead.backgroundColor = UIColor.hexInt(0xff00ff)
            return sectionHead
        } else {
            return UIView.init()
        }

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == tabView ? 44 : 0
    }
}

extension ChannelDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func panGestureRecognizerAction(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != .changed {
            currentPanY = 0
            // 每次滑动结束都清空状态
            mainScrollEnabled = false
            subScrollEnabled = false
        } else {
            let currentY = recognizer.translation(in: tabView).y
            // 说明在这次滑动过程中经过了临界点
            if mainScrollEnabled || subScrollEnabled {
                if currentPanY == 0 {
                    currentPanY = currentY  //记录下经过临界点是的 y
                }
                let offsetY = currentPanY - currentY //计算在临界点后的 offsetY

                if mainScrollEnabled {
                    let supposeY = maxOffsetY + offsetY
                    if supposeY >= 0 {
                        tabView.contentOffset = CGPoint(x: 0, y: supposeY)
                    } else {
                        tabView.contentOffset = CGPoint.zero
                    }
                } else {
                    latestTab.contentOffset = CGPoint(x: 0, y: offsetY)
                    hotTableView.contentOffset = CGPoint(x: 0, y: offsetY)
                }
            }
        }
    }
}
