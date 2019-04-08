//
//  PersonalCenterViewController.swift
//  RxTripshow
//
//  Created by aby on 2018/8/20.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

// swiftlint:disable identifier_name
struct PersonalInput: MVVMInput {
    init(view: MVVMView) {

    }
    let updateUserInfoDriver = PublishSubject<Void>.init()
}

class PersonalCenterViewController: MVVMView, UITableViewDelegate {

    override var inputType: MVVMInput.Type? { return PersonalInput.self }

    private let cellID = "PersonalCell"

    var persional_input: PersonalInput? {
        return (self.viewModel?.input as? PersonalInput)
    }

    lazy var tableview: UITableView = {
        let tab = UITableView.init(frame: CGRect.zero)
        tab.separatorStyle = .none
        tab.contentInsetAdjustmentBehavior = .never
        tab.backgroundColor = S_tabBackColor
        tab.rowHeight = W750(118)
        return tab
    }()

    let avatar: UIImageView = UIImageView.init()
    let name: UILabel = UILabel.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.white
        view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view)
        }
        setheaderView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.viewModel?.input as! PersonalInput).updateUserInfoDriver.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func rxDrive(viewModelOutput: MVVMOutput) {
        let output = viewModelOutput as! PersonalViewModel.PersonalOutput
        output.name.drive(name.rx.text).disposed(by: disposeBag)
        output.avatar.drive(onNext: { (url) in
            self.avatar.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "user_icon"))
        }).disposed(by: disposeBag)
        bindTableView(output)
    }

    private func bindTableView(_ output: PersonalViewModel.PersonalOutput) {
        tableview.register(PersonCell.self, forCellReuseIdentifier: self.cellID) // 注册Cell
        tableview.rx.setDelegate(self).disposed(by: self.disposeBag)
        output.listData.drive(tableview.rx.items(cellIdentifier: self.cellID, cellType: PersonCell.self)) { (_, item, cell) in
            cell.icon.image = item.0
            cell.title.text = item.1
        }.disposed(by: self.disposeBag)
        tableview.rx.itemSelected.subscribe(onNext: { (indexPath) in
            DTLog("点击了\(indexPath)")
        }).disposed(by: self.disposeBag)
    }

    private func setheaderView() {
        let headerView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: view.width, height: W750(560)))
        headerView.image = #imageLiteral(resourceName: "mine_back")
        headerView.isUserInteractionEnabled = true
        headerView.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.width.height.equalTo(W750(160))
            make.centerY.equalTo(headerView.snp.centerY).offset(W750(-40))
            make.centerX.equalTo(headerView.snp.centerX)
        }
        avatar.contentMode = .scaleAspectFit
        headerView.addSubview(name)
        name.snp.makeConstraints { (make) in
            make.centerX.equalTo(headerView.snp.centerX)
            make.top.equalTo(avatar.snp.bottom).offset(W750(20))
        }
        name.textColor = S_textWhite
        tableview.tableHeaderView = headerView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
