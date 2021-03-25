//
//  LogInPage.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/3/24.
//

import Foundation
import UIKit


class LoginController: UINavigationController {
    
    var loginView = UIView()
    
    var loginTitle = UILabel()
    var subTitle = UILabel()
    
    var zhihuLogin = UIButton()
    var weiboLogin = UIButton()
    var backButton = UIButton()
    
    var setButton = UIButton()
    var setLabel = UILabel()
    var nightButton = UIButton()
    var nightLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loginView)
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height

        loginView.snp.makeConstraints({make -> Void in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        })
        loginView.backgroundColor = .white
        
        loginView.addSubview(loginTitle)
        loginTitle.text = "登录知乎日报"
        loginTitle.adjustsFontSizeToFitWidth = true
        loginTitle.font = UIFont.systemFont(ofSize: 40, weight: .black)
        loginTitle.snp.makeConstraints({make -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-width/2)
            make.height.equalTo(width/8)
            make.width.equalTo(width/2.5)
        })
        
        loginView.addSubview(subTitle)
        subTitle.text = "选择登录方式"
        subTitle.textColor = .gray
        subTitle.snp.makeConstraints({make -> Void in
            make.top.equalTo(loginTitle.snp.bottom)
            make.centerX.equalTo(loginTitle)
            make.height.equalTo(height/20)
        })
        
        loginView.addSubview(zhihuLogin)
        loginView.addSubview(weiboLogin)
        
        zhihuLogin.setImage(UIImage(named: "zhihu"), for: .normal)
        weiboLogin.setImage(UIImage(named: "weibo"), for: .normal)
        zhihuLogin.snp.makeConstraints({make -> Void in
            make.centerX.equalToSuperview().offset(-width/7)
            make.top.equalTo(subTitle.snp.bottom).offset(width/8)
            make.size.equalTo(width/6.5)
        })
        weiboLogin.snp.makeConstraints({make -> Void in
            make.centerX.equalToSuperview().offset(width/7)
            make.top.equalTo(subTitle.snp.bottom).offset(width/8)
            make.size.equalTo(width/6.5)
        })
        
        loginView.addSubview(backButton)
        backButton.snp.makeConstraints({make -> Void in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(width/14)
            make.left.equalToSuperview().offset(width/25)
        })
        backButton.setImage(UIImage(systemName: "chevron.compact.left"), for: .normal)
        backButton.tintColor = .black
        
//        backButton.contentHorizontalAlignment = .fill
//        backButton.contentVerticalAlignment = .fill
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large )
        backButton.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        
        
        let setConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular, scale: .large)
        
        loginView.addSubview(setButton)
        loginView.addSubview(setLabel)
        setButton.snp.makeConstraints({make -> Void in
            make.bottom.equalToSuperview().offset(-height/8)
            make.centerX.equalToSuperview().offset(width/5)
            make.size.equalTo(width/4)
        })
        setButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        setButton.tintColor = .black
        setButton.setPreferredSymbolConfiguration(setConfig, forImageIn: .normal)
        setLabel.snp.makeConstraints({make -> Void in
            make.top.equalTo(setButton.snp.bottom)
            make.centerX.equalTo(setButton)
            make.width.equalTo(width/3)
            make.height.equalTo(20)
        })
        setLabel.text = "设置"
        setLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        setLabel.textAlignment = .center
        
        
        loginView.addSubview(nightButton)
        loginView.addSubview(nightLabel)
        nightButton.tintColor = .black
        nightButton.snp.makeConstraints({make -> Void in
            make.bottom.equalToSuperview().offset(-height/8)
            make.centerX.equalToSuperview().offset(-width/5)
            make.size.equalTo(width/4)
        })
        nightButton.setImage(UIImage(systemName: "moon"), for: .normal)
        nightButton.setPreferredSymbolConfiguration(setConfig, forImageIn: .normal)
        nightLabel.snp.makeConstraints({make -> Void in
            make.top.equalTo(nightButton.snp.bottom)
            make.centerX.equalTo(nightButton)
            make.width.equalTo(width/3)
            make.height.equalTo(20)
        })
        nightLabel.text = "夜间模式"
        nightLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        nightLabel.textAlignment = .center
        
    }
}


extension LoginController {
    @objc func back() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
}
