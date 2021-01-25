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
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        guard container != nil else {
                    fatalError("This view needs a persistent container.")
                }
        self.view.addSubview(mainTableView)
        mainTableView.snp.makeConstraints( { make -> Void in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        })
        mainTableView.delegate = self
        mainTableView.dataSource = self
        AF.request("https://news-at.zhihu.com/api/3/news/latest").responseJSON(completionHandler: {response in
            switch response.result {
            case .success(let json):
                
                let data = JSON(json)
                var  stories = data["stories"].array!
                for store in stories {
                    var title = store["title"].stringValue
                    self.titleCollection.append(title)
                }
                self.mainTableView.reloadData()
                
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
