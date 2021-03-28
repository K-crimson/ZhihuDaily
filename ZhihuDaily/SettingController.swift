//
//  settingController.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/3/28.
//

import Foundation
import UIKit


class settingController: UINavigationController {
    
    var settingView = UIView()
    var backButton = UIButton()
    var clearCache = UIButton()
    
    @objc func back() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    @objc func warning() {
        let alertController = UIAlertController(title: nil, message: "确认清空缓存？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "确认", style: .destructive, handler: {_ in
            deleteImages()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        view.addSubview(settingView)
        settingView.backgroundColor = .white
        settingView.snp.makeConstraints({
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        })
        
        settingView.addSubview(backButton)
        backButton.snp.makeConstraints({make -> Void in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.size.equalTo(width/14)
            make.left.equalToSuperview().offset(width/25)
        })
        backButton.setImage(UIImage(systemName: "chevron.compact.left"), for: .normal)
        backButton.tintColor = .black
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large )
        backButton.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        settingView.addSubview(clearCache)
        clearCache.snp.makeConstraints({
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(3)
            $0.height.equalTo(width/9)
        })
        
        clearCache.setTitle("清除缓存", for: .normal)
        clearCache.setTitleColor(.red, for: .normal)
        clearCache.addTarget(self, action: #selector(warning), for: .touchUpInside)
    }
    
    
    
    
}
