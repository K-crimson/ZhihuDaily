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
import FSPagerView





class ViewController: UIViewController {

    lazy var mainTableView: UITableView = {
//        frame: CGRect(x: 200, y: 200, width: 200, height: 200), style: .grouped
        return UITableView(frame: .zero, style: .grouped)
    }() //主界面的UITableView
    
    lazy var banner: FSPagerView = {
        return FSPagerView()
    }()
    
    lazy var pageControl: FSPageControl = {
        return FSPageControl()
    }()
    
    var navigationBar = UINavigationBar()
    var bannerView = UIView()
    var container: NSPersistentContainer!
    var keys = [Int32]()                //将date存入数组中 作为TableView划分section的依据
    var stories = [Int32: [Story]]()   //对CoreData中的数据以date为key进行存储
    var dates = [String]()
    var topStories = readTopStory()
    var topImages = [UIImage]()
    var topTitles = [String]()
    var topHints = [String]()
    var topIds = [Int32]()
    
    @objc func reloaddata() {
//        mainTableView.reloadData()
//
//
////        banner.reloadData()
//
//        print(topStories)
//        print("iahbvakhjdb\(topImages)")
//        print(topTitles)
//        print(topHints)
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        view.addSubview(mainTableView)
        navigationItem.title = "知乎日报"
        view.addSubview(navigationBar)
        
        navigationBar.snp.makeConstraints({make -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
        })
        navigationBar.backgroundColor = .blue

        
        mainTableView.addSubview(bannerView)
        bannerView.addSubview(banner)
        bannerView.addSubview(pageControl)
        bannerView.snp.makeConstraints({make -> Void in
            
            make.width.equalTo(mainTableView)
            make.height.equalTo(400)
        })
        banner.snp.makeConstraints({make -> Void in
            
            make.width.equalTo(mainTableView)
            make.height.equalTo(400)
        })
        pageControl.snp.makeConstraints({make -> Void in
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalToSuperview().offset(-50)
        })
        banner.backgroundColor = .green
        banner.delegate = self
        banner.dataSource = self
        banner.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        banner.isInfinite = true
        banner.automaticSlidingInterval = 5
//        banner.isHidden = true
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.setStrokeColor(.gray, for: .normal)
        pageControl.setStrokeColor(.white, for: .selected)
        pageControl.setFillColor(.gray, for: .normal)
        pageControl.setFillColor(.white, for: .selected)
        
        for TopStory in topStories {
            if let image = readImage(of: TopStory.id) {
                if !topImages.contains(image) {
                    topImages.append(image)
                }
            }
            if let title = TopStory.title {
                if !topTitles.contains(title) {
                    topTitles.append(title)
                }
            }
            if let hint = TopStory.hint {
                if !topHints.contains(hint) {
                    topHints.append(hint)
                }
            }
            if !topIds.contains(TopStory.id) {
                topIds.append(TopStory.id)
            }
        }

        do {
            mainTableView.snp.makeConstraints( { make -> Void in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
                make.top.equalTo(navigationBar.snp.bottom)
            })
        }
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .none
        mainTableView.contentInsetAdjustmentBehavior = .never
        mainTableView.backgroundColor = .white
//        writeLatestStory()
//        writePreviousStory()
        
//        NotificationCenter.default.addObserver(writeLatestStory(), selector: #selector(reloaddata), name: Notification.Name(rawValue: "newspaperLoaded"), object: nil)
//        deleteAllStory()
//        deleteAllTop()
        storeImage()
        for top in readTopStory() {
            print(top.hint)
        }
        
        
       
        //将CoreData中date的值存入集合中，以获得无重复的日期值
        var groups = Set<Int32>()
        for story in readStory() {
            groups.insert(story.date)
        }
        keys = groups.sorted(by: >)
        //将CoreData中的元素按相同日期归至同一数组
        var emptyStory = Story()
        if let empty = readStory().first {
            emptyStory = empty
        }
//        emptyStory.id = 1
        
        
        
        readStory().forEach { story in
            stories[story.date, default: []].append(story)
        }
        
//        此处可能出现数组溢出
        
//            stories[keys[0]]?.insert(emptyStory, at: 0)
        
//        TODO 日期为十位数时出现错误
        for key in keys {
            var month,date: String
            month = String((key / 100) % 10)
            date = String(key % 10)
            dates.append("\(month)月\(date)日")
        }
        
       print(topIds)
        
    }
    
    override func viewDidLayoutSubviews() {
        
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
        if indexPath.section == 0 && indexPath.row == 0 {
            return 400
        } else {
            return 100
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return newHeaderForSection(String(dates[section]), section)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifer = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifer)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifer)
        }
        
        let story = stories[keys[indexPath.section], default: []][indexPath.row]
        
        cell?.textLabel?.text = story.title
        cell?.textLabel?.numberOfLines = 2
        cell?.detailTextLabel?.text = story.hint
        cell?.detailTextLabel?.textColor = .gray
        
        let imageView = UIImageView(image: readImage(of: story.id))
        imageView.frame.size = CGSize(width: 70, height: 70)
        imageView.contentMode = .scaleAspectFit
        imageView.makeViewRoundCorner()
        cell?.accessoryView = imageView
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailPage = DetailController()
        detailPage.modalPresentationStyle = .fullScreen
        detailPage.modalTransitionStyle = .partialCurl
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        let story = stories[keys[indexPath.section], default: []][indexPath.row]
        detailPage.id = story.id
        for key in keys {
            for id in stories[key] ?? [] {
                detailPage.ids.append(id.id)
            }
        }
        
        self.present(detailPage, animated: false, completion: nil)
        
    }
    
}

extension ViewController: FSPagerViewDelegate, FSPagerViewDataSource {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 5
    }


    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let page = UIView()
        let imageView = UIImageView()
        let title = UILabel()
        let hint = UILabel()
        cell.contentView.addSubview(page)
        page.snp.makeConstraints({make -> Void in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        })
        page.addSubview(imageView)
        page.addSubview(title)
        page.addSubview(hint)
        imageView.image = topImages[index]
        hint.text = topHints.isEmpty ? "" : topHints[index]
        title.text = topHints.isEmpty ? "" : topTitles[index]
        imageView.snp.makeConstraints({make -> Void in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        })


        hint.textColor = .gray
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        hint.snp.makeConstraints({make -> Void in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        })
        title.snp.makeConstraints({make -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalTo(hint.snp.top)
        })
        
        return cell
        
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let detailPage = TopController()
        detailPage.modalPresentationStyle = .fullScreen
        detailPage.modalTransitionStyle = .partialCurl
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        detailPage.id = topIds[index]
        detailPage.ids = topIds
        self.present(detailPage, animated: false, completion: nil)
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
            self.pageControl.currentPage = index
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
                imageView.downloadedFrom(link: link)
            }else {
                print("imageUrl in storie is empty")
            }
            /// TODO: 此处存储图片使用了延时执行 使图片在进行保存前下载成功 后续需改进
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let image = imageView.image
                var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                documentsPath.appendPathComponent("\(story.id).jpg")
                var data = Data()
                if let image = image?.jpegData(compressionQuality: 1.0) {
                    data = image
                }
//                let data = image!.jpegData(compressionQuality: 1.0)
                FileManager.default.createFile(atPath: documentsPath.path, contents: data, attributes: nil)
            }
        }
        for TopStory in readTopStory() {
            var imageView = UIImageView()
            if let link = TopStory.image {
                imageView.downloadedFrom(link: link)
            }else {
                print("imageUrl in storie is empty")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let image = imageView.image
                var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                documentsPath.appendPathComponent("\(TopStory.id).jpg")
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
    
    
    
    func newHeaderForSection(_ date: String, _ section :Int) -> UIView {
        if section == 0 {
            return bannerView
        }else {
            var backView = UIView()
            backView.backgroundColor = UIColor.white
            let line = UIView()
            backView.addSubview(line)
            line.backgroundColor = .gray
            line.snp.makeConstraints({make -> Void in
                make.center.equalToSuperview()
                make.height.equalTo(0.4)
                make.right.equalToSuperview()
                make.left.equalToSuperview().offset(80)
            })
            let textView = UIButton()
            backView.addSubview(textView)
            textView.setTitle(date, for: .normal)
            textView.setTitleColor(.gray, for: .normal)
            textView.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            textView.backgroundColor = .white
            textView.snp.makeConstraints({make -> Void in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
                make.width.equalTo(80)
                make.height.equalTo(10)
            })
            return backView
        }
        
    }
    
}

extension UIView {
    
    /// 将UIView进行圆角处理
    func makeViewRoundCorner() {
        layer.cornerRadius = frame.width / 32
        layer.masksToBounds = true
    }
    
    
}

extension UITextView {
    
    /// 垂直对齐
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}


