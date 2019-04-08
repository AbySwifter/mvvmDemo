//
//  ChannelViewController.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MJRefresh

class ChannelViewController: MVVMView, UITableViewDelegate {

    fileprivate let cellID = "ChannelCell"
    lazy var tableView: UITableView = {
        let tab = UITableView.init(frame: CGRect.zero)
        view.addSubview(tab)
        tab.snp.makeConstraints({ (make: ConstraintMaker) in
            make.top.bottom.left.right.equalTo(view)
        })
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view.
        self.getInput?.requestCommond.onNext(true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return W750(350)
    }
    // MARK: - MVVM Method
    var getInput: ChannelInput? {
        return self.viewModel?.input as? ChannelInput
    }
    struct ChannelInput: MVVMInput {
        init(view: MVVMView) {

        }
        let requestCommond = PublishSubject<Bool>.init()
    }
    override var inputType: MVVMInput.Type? { return ChannelInput.self }
    override func rxDrive(viewModelOutput: MVVMOutput) {
        let vmOutput = viewModelOutput as! ChannelViewModel.ChannelOutPut
        bindTab(output: vmOutput)
        vmOutput.refreshStatus.asObservable()
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
            }).disposed(by: disposeBag)
    }
    override func rxBind(viewInput: MVVMInput) {
        let input = viewInput as! ChannelInput
        tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            input.requestCommond.onNext(true)
        })
    }
    private func bindTab(output: ChannelViewModel.ChannelOutPut) {
        tableView.register(ChannelCell.self, forCellReuseIdentifier: self.cellID)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

        output.listData.drive(tableView.rx.items(cellIdentifier: self.cellID, cellType: ChannelCell.self)) { (_, element, cell) in
            cell.setCell(model: element)
            }.disposed(by: self.disposeBag)
        tableView.rx.modelSelected(ChannelModel.self).subscribe(onNext: { (model) in
            _ = self.router.route(RouterType.push(.channelDetail), send: Driver.just(model)) // 将当前的频道模型传递出去
        }).disposed(by: self.disposeBag)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
    }

}
