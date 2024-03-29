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
    var clearCache = UIButton(type: .system)
    var cacheSizeLabel = UILabel()
    
    
    /// 返回登陆界面
    @objc func back() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    /// 弹出确认清除缓存窗口
    @objc func warning() {
        let alertController = UIAlertController(title: nil, message: "确认清空缓存？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "确认", style: .destructive, handler: {_ in
            deleteCaches()
            self.cacheSizeLabel.text = "0.00 M"
        })
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        view.addSubview(settingView)
        settingView.backgroundColor = .systemBackground
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
        backButton.tintColor = UIColor(named: "TextColor")
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large )
        backButton.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        settingView.addSubview(clearCache)
        clearCache.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
            $0.width.equalToSuperview().dividedBy(3)
            $0.height.equalTo(width/9)
        })
        
        clearCache.setTitle("清除缓存", for: .normal)
        clearCache.titleLabel?.font = UIFont.systemFont(ofSize: width/20)
        clearCache.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        clearCache.addTarget(self, action: #selector(warning), for: .touchUpInside)
        
        

        
        let manager = FileManager.default
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        var fileArray = [String]()
        do {
            try  fileArray = manager.subpathsOfDirectory(atPath: documentsPath)
        } catch {
            print("文件错误\(error)")
        }
        
        var totalSize = Double()
        for file in fileArray {
            do {
                let attributes = try manager.attributesOfItem(atPath: "\(documentsPath)" + "/\(file)")
                let size: Double = attributes[FileAttributeKey.size]! as? Double ?? 0
                totalSize += size
            } catch {
                print(error)
            }
        }
        totalSize /= 1000000
        let number = NSNumber(value: totalSize)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let sizeString = formatter.string(from: number)
        
        /// 读取缓存文件大小
        
        settingView.addSubview(cacheSizeLabel)
        cacheSizeLabel.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview()
            $0.size.equalTo(clearCache)
        })
        cacheSizeLabel.text = String(sizeString ?? "0") + " M"
        cacheSizeLabel.textAlignment = .center
        cacheSizeLabel.textColor = UIColor(named: "TextColor")
    }
}
