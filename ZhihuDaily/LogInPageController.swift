//
//  LogInPage.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/3/24.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Toast_Swift
import CoreData

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
    
    var profile = UIImageView()
    var userName = UILabel()
    var animateView = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .black)
    
    var signOutButton = UIButton()
    
    
    
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
        zhihuLogin.addTarget(self, action: #selector(login), for: .touchUpInside)
        weiboLogin.snp.makeConstraints({make -> Void in
            make.centerX.equalToSuperview().offset(width/7)
            make.top.equalTo(subTitle.snp.bottom).offset(width/8)
            make.size.equalTo(width/6.5)
        })
        weiboLogin.addTarget(self, action: #selector(login), for: .touchUpInside)

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
        
        
        
        let setConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)
        
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
        setButton.addTarget(self, action: #selector(setPage), for: .touchUpInside)
        setLabel.snp.makeConstraints({make -> Void in
            make.top.equalTo(setButton.snp.bottom).inset(width/19)
            make.centerX.equalTo(setButton)
            make.width.equalTo(width/3)
            make.height.equalTo(20)
        })
        setLabel.text = "设置"
        setLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
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
        nightButton.addTarget(self, action: #selector(changeUserInterfaceStyle), for: .touchUpInside)
        nightLabel.snp.makeConstraints({make -> Void in
            make.top.equalTo(nightButton.snp.bottom).inset(width/19)
            make.centerX.equalTo(nightButton)
            make.width.equalTo(width/3)
            make.height.equalTo(20)
        })
        nightLabel.text = "夜间模式"
        nightLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        nightLabel.textAlignment = .center
        
//        loginTitle.isHidden = true
//        subTitle.isHidden = true
//        zhihuLogin.isHidden = true
//        weiboLogin.isHidden = true
        
        loginView.addSubview(animateView)
        animateView.snp.makeConstraints({make -> Void in
            make.center.equalToSuperview()
            make.size.equalTo(width/12)
        })
        
        loginView.addSubview(profile)
        profile.snp.makeConstraints({make -> Void in
            make.centerY.equalTo(zhihuLogin.snp.top)
            make.centerX.equalToSuperview()
        })
        profile.frame.size = CGSize(width: width/3, height: width/3)
        profile.image = UIImage(named: "profile")
//        profile.contentMode = .scaleAspectFit
        profile.makeViewRoundCorner(0.73)
        profile.isHidden = true
        
        loginView.addSubview(userName)
        userName.snp.makeConstraints({make -> Void in
            make.top.equalTo(profile.snp.bottom).offset(width/20)
            make.width.equalTo(width/3)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        })
        userName.text = "知乎用户"
        userName.textAlignment = .center
        userName.font = UIFont.systemFont(ofSize: 20)
        userName.isHidden = true
        
        loginView.addSubview(signOutButton)
        signOutButton.snp.makeConstraints({make -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(userName.snp.bottom).offset(width/20)
            
        })
        signOutButton.setTitle("退出登录", for: .normal)
        signOutButton.setTitleColor(.red, for: .normal)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        signOutButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToDark), name: Notification.Name(rawValue: "dark"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToLight), name: Notification.Name(rawValue: "light"), object: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext)
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.fetchOffset = 0
        request.fetchLimit = 1
        request.entity = entity
        
        do {
            let results: [AnyObject]? = try managedObjectContext.fetch(request)
            if results?.count == 0 {
                profile.isHidden = true
                userName.isHidden = true
                signOutButton.isHidden = true
                loginTitle.isHidden =  false
                subTitle.isHidden = false
                zhihuLogin.isHidden = false
                weiboLogin.isHidden = false
                let status = NSEntityDescription.insertNewObject(forEntityName: "Account", into: managedObjectContext)
                try managedObjectContext.save()
            } else {
                let status = results as! [Account]
                if status[0].logStatus == false {
                    profile.isHidden = true
                    userName.isHidden = true
                    signOutButton.isHidden = true
                    loginTitle.isHidden =  false
                    subTitle.isHidden = false
                    zhihuLogin.isHidden = false
                    weiboLogin.isHidden = false
                } else {
                loginTitle.isHidden = true
                subTitle.isHidden = true
                zhihuLogin.isHidden = true
                weiboLogin.isHidden = true
                profile.isHidden = false
                userName.isHidden = false
                signOutButton.isHidden = false
                }
            }
            print("结果是\(results)")
        } catch {
            print(error)
        }
    }
    
    
    @objc func setPage() {
        let settingPage = settingController()
        settingPage.modalTransitionStyle = .partialCurl
        settingPage.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(settingPage, animated: false, completion: nil)
    }
    
    @objc func back() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    @objc func login() {
        loginTitle.isHidden = true
        subTitle.isHidden = true
        zhihuLogin.isHidden = true
        weiboLogin.isHidden = true
        animateView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.animateView.stopAnimating()
            self.view.makeToast("登录成功")
            self.profile.isHidden = false
            self.userName.isHidden = false
            self.signOutButton.isHidden = false
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext)
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.fetchOffset = 0
        request.fetchLimit = 1
        request.entity = entity
        
        
        do {
            let results: [AnyObject]? = try managedObjectContext.fetch(request)
            
            for result in results as! [Account] {
                result.logStatus = true
            }
            try managedObjectContext.save()
            print("结果是\(results)")

        } catch {
            print(error)
        }
        
        
        
        
    }
    
    @objc func signOut() {
        profile.isHidden = true
        userName.isHidden = true
        signOutButton.isHidden = true
        animateView.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            animateView.stopAnimating()
            view.makeToast("退出登录")
            loginTitle.isHidden =  false
            subTitle.isHidden = false
            zhihuLogin.isHidden = false
            weiboLogin.isHidden = false
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Account", in: managedObjectContext)
        let request = NSFetchRequest<Account>(entityName: "Account")
        request.fetchOffset = 0
        request.fetchLimit = 1
        request.entity = entity
        
        
        do {
            let results: [AnyObject]? = try managedObjectContext.fetch(request)
            
            for result in results as! [Account] {
                result.logStatus = false
            }
            try managedObjectContext.save()
            print("结果是\(results)")

        } catch {
            print(error)
        }
    }
    
    @objc func changeUserInterfaceStyle() {
        if overrideUserInterfaceStyle == .light {
            postNotification("light")
        } else {
            postNotification("dark")
        }
    }
}
