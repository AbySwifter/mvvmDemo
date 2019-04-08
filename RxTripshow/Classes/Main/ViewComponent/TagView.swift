//
//  TagView.swift
//  RxTripshow
//
//  标签视图
//  Created by aby on 2018/9/6.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit

protocol TagItem {
    var tagName: String { get }
}

protocol TagViewDelegate {
    func touch(index: Int, tag: TagItem)
    func touchClose(index: Int, tag: TagItem)
    func touchAdd(index: Int)
}

extension TagViewDelegate {

    func touch(index: Int, tag: TagItem) {
        DTLog("执行了默认的点击方法")
    }

    func touchClose(index: Int, tag: TagItem) {
        DTLog("执行了默认的删除方法")
    }

    func touchAdd(index: Int) {}
}

class AlTagView<E: TagItem>: UIView {
    var delegate: TagViewDelegate? // 标签视图的代理
    var showAddBtn: Bool = true // 是否显示添加按钮
    /// 标签间间距
    var marginX: CGFloat = W375(20)
    /// 行高
    var rowHeight: CGFloat = W375(45)
    /// 标签数组
    var tags: Array<E> = [E]() {
        didSet {
            self.updataTag()
        }
    }
    var rowContainers: [UIView] = []
    /// 行的最大宽度
    var maxRowWidth: CGFloat = W375(375) // 默认为屏幕宽
    /// 行数
    var rowNumber: CGFloat {
        return currentRow + 1
    }
    /// 自适应的高度
    var totalHeight: CGFloat {
        return rowNumber*rowHeight
    }

    var showClose: Bool = true
    /// MARK: private proprites
    private var totalRowW: CGFloat = 0 // 用来记录当前最后一行的宽度
    private var currentRow: CGFloat = 0 // 记录当最后一行的行数
    private var lastButton: UIButton? // 记录当前最后一个button（为nil说明需要换行）

    lazy var addButton: UIButton = {
        let button = UIButton.init()
        button.setTitle("添加标签", for: .normal)
        button.setTitleColor(UIColor.init(hexString: "adadad"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: W375(14))
        button.setBackgroundImage(UIColor.white.trans2Image(), for: .normal)
        let bounds = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: W375(83), height: W375(30)))
        let border = CAShapeLayer.init()
        border.strokeColor = UIColor.init(hexString: "adadad").cgColor
        border.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath.init(roundedRect: bounds, cornerRadius: W375(15))
        border.path = path.cgPath
        border.frame = bounds
        border.lineWidth = 1.0
        border.lineDashPattern = [NSNumber.init(value: 4), NSNumber.init(value: 2)]
        button.layer.cornerRadius = W375(15)
        button.layer.masksToBounds = true
        button.layer.addSublayer(border)
        button.addTarget(self, action: #selector(addBtnAction(_ :)), for: .touchUpInside)
        return button
    }()

    // MARK: Initial Methods

    /// 快捷初始化方法
    ///
    /// - Parameters:
    ///   - tags: 标签数组
    ///   - maxRowW: 最大行宽
    ///   - rowH: 最大行高
    ///   - marginX: 标签间距
    ///   - showAddBtn: 是否展示添加Btn
    ///   - showClose: 是否展示关闭Btn
    convenience init(tags: [E], maxRowW: CGFloat, rowH: CGFloat, marginX: CGFloat, showAddBtn: Bool = true, showClose: Bool = true) {
        self.init()
        self.marginX = marginX
        self.maxRowWidth = maxRowW
        self.rowHeight = rowH
        self.tags = tags
        self.showAddBtn = showAddBtn
        self.showClose = showClose
        self.createTags()
    }

    func updataTag() {
        for item in self.subviews {
            item.removeFromSuperview()
        }
        lastButton = nil
        currentRow = 0
        totalRowW = 0
        rowContainers.removeAll()
        self.createTags() // 重新创建
    }

    // MARK: Internal Methods
    private func createTag(title: String) -> UIButton {
        let button = UIButton.init(bgColor: UIColor.init(hexString: "c3c3c3"), disabledColor: nil, title: title, titleColor: UIColor.init(hexString: "ffffff"), titleHighlightedColor: nil)
        button.titleLabel?.font = UIFont.systemFont(ofSize: W375(14))
        button.addTarget(self, action: #selector(tagTouchAction(_:)), for: .touchUpInside)
        button.layer.cornerRadius = W375(15)
        button.adjustsImageWhenHighlighted = true
        return button
    }

    private func createClose() -> UIButton {
        let button = UIButton.init(type: .custom)
        button.setImage(#imageLiteral(resourceName: "tag_close"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        return button
    }

    private func addClose(in button: UIButton, tag: Int) {
        let close = createClose()
        close.tag = tag
        self.addSubview(close)
        close.snp.makeConstraints { (make) in
            make.top.equalTo(button.snp.top)
            make.right.equalTo(button.snp.right).offset(5)
            make.height.width.equalTo(W375(15))
        }
    }

    // MARK: Public Methods
    // swiftlint:disable function_body_length
    func createTags() {
        let btnHeight: CGFloat = W375(30) // 每个按钮的高度
        let rowMarginTop: CGFloat = (rowHeight - btnHeight) / 2
        var needChangeline: Bool = false
        var currentRowContainer: UIView!
        for index in 0..<tags.count {
            if rowContainers.count == Int(currentRow + 1) {
                currentRowContainer = rowContainers[Int(currentRow)]
            } else {
                currentRowContainer = UIView.init()
                rowContainers.append(currentRowContainer)
                self.addSubview(currentRowContainer)
                currentRowContainer.snp.makeConstraints { (make) in
                    make.top.equalTo(self.snp.top).offset(currentRow*rowHeight + rowMarginTop)
                    make.height.equalTo(btnHeight)
                    make.centerX.equalTo(self)
                    make.width.equalTo(100)
                }
            }
            let button = createTag(title: tags[index].tagName)
            // 决定是否可以点击
            button.isEnabled = !showClose
            //自适应title的宽度
            button.titleLabel?.sizeToFit()
            button.tag = 1000 + index // button的tag是1000以上
            var btnW = (button.titleLabel?.bounds.width)! + W375(20)
            // 判断是否需要换行
            if btnW < maxRowWidth - totalRowW {
                // 不需要换行
                needChangeline = false
                totalRowW += btnW + marginX
            } else {
                needChangeline = true
                // 需要换行
                if btnW > maxRowWidth {
                    // 如果标签的宽度比最大的还宽，那就得处理一下了
                    btnW = maxRowWidth
                }
                currentRow += 1 // 行数加1
                totalRowW = btnW + marginX
            }
            currentRowContainer.addSubview(button)
//            self.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerY.equalTo(currentRowContainer.snp.centerY)
//                make.top.equalTo(self.snp.top).offset(currentRow*rowHeight + rowMarginTop)
                make.height.equalTo(btnHeight)
                make.width.equalTo(btnW)
            }
            if needChangeline || lastButton == nil {
                button.snp.makeConstraints { (make) in
                     make.left.equalTo(currentRowContainer.snp.left)
//                    make.left.equalTo(self.snp.left)
                }
            } else {
                button.snp.makeConstraints { (make) in
                    make.left.equalTo(lastButton!.snp.right).offset(marginX)
                }
                currentRowContainer.snp.updateConstraints { (make) in
                    make.width.equalTo(totalRowW - marginX)
                }
            }
            if showClose {
                // 添加Close按钮
                addClose(in: button, tag: 2000 + index)
            }
            lastButton = button
        }
        // 如果需要添加addbtn，就添加addbtn
        if showAddBtn {
            var btnW = W375(103)
            // 判断是否需要换行
            if btnW < maxRowWidth - totalRowW {
                // 不需要换行
                needChangeline = false
                totalRowW += btnW + marginX
            } else {
                needChangeline = true
                // 需要换行
                if btnW > maxRowWidth {
                    // 如果标签的宽度比最大的还宽，那就得处理一下了
                    btnW = maxRowWidth
                }
                currentRow += 1 // 行数加1
                totalRowW = btnW + marginX
            }
            self.addSubview(addButton)
            addButton.snp.makeConstraints { (make) in
                make.width.equalTo(W375(83))
                make.height.equalTo(W375(30))
                make.top.equalTo(self.snp.top).offset(currentRow*rowHeight + rowMarginTop)
                if needChangeline || lastButton == nil {
                    make.left.equalTo(self.snp.left)
                } else {
                    make.left.equalTo(lastButton!.snp.right).offset(marginX)
                }
            }
        }
        // swiftlint:enable function_body_length
    }

    @objc
    func tagTouchAction(_ sender: UIButton) {
        // 点击标签的事件
        self.delegate?.touch(index: sender.tag - 1000, tag: self.tags[sender.tag - 1000])
    }

    @objc
    func closeAction(_ sender: UIButton) {
        // 点击关闭的事件
        self.delegate?.touchClose(index: sender.tag - 2000, tag: self.tags[sender.tag - 2000])
    }

    @objc func addBtnAction(_ sender: UIButton) {
        // 点击添加事件
        self.delegate?.touchAdd(index: -1) // 执行添加按钮的点击事件
    }
}
