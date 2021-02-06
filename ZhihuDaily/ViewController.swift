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

    lazy var mainTableView: UITableView = {
        return UITableView()
    }() //主界面的UITableView
    var container: NSPersistentContainer!
    var keys = [Int32]()                //将date存入数组中 作为TableView划分section的依据
    var stories = [Int32: [Story]]()   //对CoreData中的数据以date为key进行存储
//    @objc func printsmth() {
////        for story in readStorie() {
////            print(story.date)
////            print(story.hint)
////            print(story.id)
////            print(story.title)
////            print(story.image)
////        }
//    }
    
    
     
    
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
        
        writeLatestStory()
//        writePreviousStory()
//        deleteAllStory()
        storeImage()

       
        //将CoreData中date的值存入集合中，以获得无重复的日期值
        var groups = Set<Int32>()
        for story in readStory() {
            groups.insert(story.date)
        }
        keys = groups.sorted(by:>)
        //将CoreData中的元素按相同日期归至同一数组
        readStory().forEach { story in
            stories[story.date, default: []].append(story)
        }
        
        
    }
    
    
}


    
    



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories[keys[section], default: []].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "aaa"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifer = "reusedCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifer)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifer)
        }
        
        let story = stories[keys[indexPath.section], default: []][indexPath.row]
        
        cell?.textLabel?.text = story.title
        cell?.textLabel?.numberOfLines = 2
        cell?.detailTextLabel?.text = story.hint
        cell?.detailTextLabel?.textColor = UIColor.gray
        
        let imageView = UIImageView(image: readImage(of: story.id))
        imageView.frame.size = CGSize(width: 70, height: 70)
        imageView.contentMode = .scaleAspectFit
        imageView.makeViewRoundCorner()
        cell?.accessoryView = imageView
        
        return cell!
    }

}


extension UIImageView {
    
    
    /// 下载图片
    /// - Parameter url: URL
    func downloadedFrom(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    
    /// 下载图片
    /// - Parameters:
    ///   - link: 网络链接
    func downloadedFrom(link: String) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url)
    }
    
}

extension ViewController {
    
    /// 将图片以Story的id.jpg为文件名进行存储
    func storeImage() {
        for story in readStory() {
            var imageView = UIImageView()
            if let link = story.image {
                imageView.downloadedFrom(link: "\(link)")
            }else {
                print("imageUrl in storie is empty")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let image = imageView.image
                var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                documentsPath.appendPathComponent("\(story.id).jpg")
                let data = image!.jpegData(compressionQuality: 1.0)
                FileManager.default.createFile(atPath: documentsPath.path, contents: data, attributes: nil)
            }
           
           
            
        }
    }
    
    
    /// 读取某一篇文章对应的头图
    /// - Parameter id: 文章的ID
    /// - Returns: 文章对应的头图
    func readImage(of id: Int32) -> UIImage? {
        var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsPath.appendPathComponent("\(id).jpg")
        return UIImage(contentsOfFile: documentsPath.path)
    }
}

extension UIView {
    
    /// 将UIView进行圆角处理
    func makeViewRoundCorner() {
        layer.cornerRadius = frame.width / 32
        layer.masksToBounds = true
    }
}
