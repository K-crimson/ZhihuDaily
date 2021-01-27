//
//  ViewController.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/1/23.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import CoreData

class ViewController: UIViewController {
    lazy var titleCollection = [String]()
    lazy var mainTableView: UITableView = {
        return UITableView()
    
    }()
    var container: NSPersistentContainer!
    var pictureView = UIImageView()
    var picture = UIImage(named: "pic1")
    override func viewDidLoad() {
        
        self.view.addSubview(mainTableView)
        do {
            mainTableView.snp.makeConstraints( { make -> Void in
                make.size.equalToSuperview()
                make.center.equalToSuperview()
            })
        }
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        view.addSubview(pictureView)
        pictureView.snp.makeConstraints({ make -> Void in
            make.size.width.height.equalTo(80)
            make.center.equalToSuperview()
        })
        
        pictureView.image = picture
        
        var image = picture!
        
        var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        documentsPath.appendPathComponent("filename1")
        let data = image.jpegData(compressionQuality: 1.0)
        FileManager.default.createFile(atPath: documentsPath.path, contents: data, attributes: nil)
        
        AF.request("https://news-at.zhihu.com/api/3/news/latest").responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let json):
                var url = String()
                let data = JSON(json)
                var  stories = data["stories"].array!
                for store in stories {
                    var title = store["title"].stringValue
                    self.titleCollection.append(title)
                    url = store["url"].stringValue
                }
                self.mainTableView.reloadData()
                
            print(url)
            case .failure(let jsooo):
                print(jsooo.errorDescription)
            }
        })

    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableViewCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        print("current collection \(titleCollection)")
        tableViewCell.textLabel?.text = titleCollection[indexPath.row]
        return tableViewCell
    }
    
    
}
