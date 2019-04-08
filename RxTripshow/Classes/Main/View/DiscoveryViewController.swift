//
//  DiscoveryViewController.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import MJRefresh

// MARK: - MVVM Method
struct DiscoveryInput: MVVMInput {
    init(view: MVVMView) {}
    let requestCommond = PublishSubject<Bool>.init() // 发起网络请求输入
    let cellLikeBtnTap = PublishSubject<IndexPath>.init()
}

class DiscoveryViewController: MVVMView {

    lazy var tableView: UITableView = {
        let tab = UITableView.init(frame: CGRect.zero)
        tab.register(UINib.init(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
        tab.backgroundColor = UIColor.clear
        view.addSubview(tab)
        tab.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(view)
        })
        return tab
    }()

    lazy var dataSource: RxTableViewSectionedReloadDataSource<DiscoveryTabData> = {
        let dataSource = RxTableViewSectionedReloadDataSource<DiscoveryTabData>.init(configureCell: {(_, tableView, indexPath, item: VideoItem) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
            cell.setCell(model: item, for: indexPath)
            self.bind(cell: cell, indexPath: indexPath)
            return cell
        })

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        self.tableView.separatorStyle = .none
        // 列表状态
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        (self.viewModel?.input as? DiscoveryInput)?.requestCommond.onNext(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBar(hide: true)
    }

    override var inputType: MVVMInput.Type? { return DiscoveryInput.self }
    override func rxDrive(viewModelOutput: MVVMOutput) {
        let vmOutPut = viewModelOutput as! DiscoveryOutput
        // 绑定数据用dataSource的方式
        vmOutPut.videoList.asDriver()
            .drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        tableView.rx.modelSelected(VideoItem.self)
            .asDriver()
            .drive(onNext: { (item) in
                DTLog(item)
               _ = self.route(.push(.videoDetail), send: Driver.just(item))
            }).disposed(by: self.disposeBag)
        // 设置刷新状态
        vmOutPut.refreshStatus.asObservable()
            .subscribe(onNext: { (status) in
                switch status {
                case .none:
                    break
                case .beingHeaderRefresh:
                    self.tableView.mj_header.beginRefreshing()
                case .endHeaderRefresh:
                    self.tableView.mj_header.endRefreshing()
                case .beingFooterRefresh:
                    self.tableView.mj_footer.beginRefreshing()
                case .endFooterRefresh:
                    self.tableView.mj_footer.endRefreshing()
                case .noMoreData:
                    break
                }
            }).disposed(by: self.disposeBag)
        vmOutPut.routeAction.drive(onNext: { (unit) in
            if let unitCase = unit {
                _ = self.route(RouterType.present(unitCase)) // present
            }
        }).disposed(by: self.disposeBag)
    }

    override func rxBind(viewInput: MVVMInput) {
        let input = viewInput as! DiscoveryInput
        // 应该是在Input里面处理
        let header = MJRefreshNormalHeader.init()
        header.stateLabel.textColor = UIColor.white
        header.lastUpdatedTimeLabel.textColor = UIColor.white
        header.rx.refreshing.map { () -> Bool in
            return true
        }.subscribe(input.requestCommond.asObserver()).disposed(by: self.disposeBag)
        tableView.mj_header = header
        tableView.mj_footer = MJRefreshAutoNormalFooter.init()
        tableView.mj_footer.rx.refreshing.map { () -> Bool in
            return false
        }.subscribe(input.requestCommond.asObserver()).disposed(by: self.disposeBag)
    }
}

extension DiscoveryViewController {
    // 绑定Input与Cell
    private func bind(cell: VideoCell, indexPath: IndexPath) {
        let input = self.viewModel?.input as! DiscoveryInput
        cell.likedBtn.rx.tap.asObservable().subscribe(onNext: { () in
            input.cellLikeBtnTap.onNext(indexPath)
        }).disposed(by: cell.disposeBag)
    }
}

extension DiscoveryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return W750(480)
    }

}
