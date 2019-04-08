//
//  SignInViewController.swift
//  RxTripshow
//
//  Created by aby on 2018/8/24.
//  Copyright © 2018 aby. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

struct SignInput: MVVMInput {
    init(view: MVVMView) {
        let view = view as! SignInViewController
        username = view.usernameTextField.rx.text.orEmpty.asDriver()
        password = view.passwordTextField.rx.text.orEmpty.asDriver()
    }
    let username: Driver<String>
    let password: Driver<String>
    let signInTap: PublishSubject<Void> = PublishSubject<Void>.init()
}

class SignInViewController: MVVMView {
    lazy var usernameTextField: UITextField = {
        let uName = UITextField.init(frame: CGRect.zero)
        uName.placeholder = "请输入用户名"
        return uName
    }()

    lazy var passwordTextField: UITextField = {
        let pwd = UITextField.init(frame: CGRect.zero)
        pwd.placeholder = "请输入密码"
        return pwd
    }()

    lazy var signInButton: UIButton = {
        let btn = UIButton.init(bgColor: UIColor.hexInt(0x8ab71b), disabledColor: UIColor.hexInt(0x999999), title: "登录", titleColor: S_textWhite, titleHighlightedColor: nil)
        btn.layer.cornerRadius = W750(32)
        return btn
    }()

    lazy var signUpLabel: UILabel = {
        let sLabel = UILabel.init(frame: CGRect.zero)
        let content = "还没有账号？请注册"
        let attStr = NSMutableAttributedString.init(string: content, attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let range = content.range(of: "注册")
        attStr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hexInt(0x8ab71b), range: content.nsRange(from: range!))
        sLabel.attributedText = attStr
        return sLabel
    }()

    lazy var userProtocl: UILabel = {
        let up = UILabel.init(frame: CGRect.zero)
        let content = "登录或注册表示您同意用户协议"
        let attStr = NSMutableAttributedString.init(string: content, attributes: [.font: UIFont.systemFont(ofSize: 14)])
        let range = content.range(of: "用户协议")
        attStr.addAttribute(.underlineStyle, value: 1, range: content.nsRange(from: range!))
        up.attributedText = attStr
        return up
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeContraints() // 绘制布局
        makeSurface() // 绘制样式
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // Do any additional setup after loading the view.
    }

    // MARK: MVVM Method
    override var inputType: MVVMInput.Type? { return SignInput.self }

    override func rxDrive(viewModelOutput: MVVMOutput) {
        let output = viewModelOutput as! SignViewModel.SignOutPut
        output.everyThingValid.drive(signInButton.rx.isEnabled).disposed(by: self.disposeBag)
        output.singInAction.drive(onNext: { (reslut) in
            if reslut.0 {
               _ = self.router.route(RouterType.back)
            } else {
                // 这里showToast
                self.view.makeToast(reslut.1, duration: 1.0, position: .bottom)
            }
        }).disposed(by: self.disposeBag)
    }

    override func rxBind(viewInput: MVVMInput) {
        let input = viewInput as! SignInput
        signInButton.rx.tap.subscribe(input.signInTap.asObserver()).disposed(by: self.disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBorder(originView: usernameTextField)
        addBorder(originView: passwordTextField)
    }

    // 点击空白处收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

extension SignInViewController {

    private func makeContraints() {
        view.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(W750(180))
            make.left.equalTo(view).offset(W750(144))
            make.right.equalTo(view).offset(W750(-144))
            make.height.equalTo(40)
        }
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom).offset(W750(36))
            make.left.right.equalTo(usernameTextField)
            make.height.equalTo(40)
        }
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(W750(84))
            make.width.equalTo(W750(324))
            make.height.equalTo(W750(65))
            make.centerX.equalTo(view.snp.centerX)
        }
        view.addSubview(signUpLabel)
        signUpLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signInButton.snp.bottom).offset(W750(36))
            make.centerX.equalTo(view)
        }
        view.addSubview(userProtocl)
        userProtocl.snp.makeConstraints { (make) in
            make.top.equalTo(signUpLabel.snp.bottom).offset(W750(36))
            make.centerX.equalTo(view)
        }
    }

    private func makeSurface() {
        view.backgroundColor = UIColor.white
        signInButton.isEnabled = false
    }

    private func addBorder(originView: UIView) {
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint.init(x: 0, y: originView.height))
        bezierPath.addLine(to: CGPoint.init(x: originView.width, y: originView.height))
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = 3 / UIScreen.main.scale
        originView.layer.addSublayer(shapeLayer)
    }
}
