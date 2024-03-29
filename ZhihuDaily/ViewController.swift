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
import ESPullToRefresh
import NVActivityIndicatorView




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
    
    // 获取屏幕宽度进行动态布局以及屏幕适配
    let width = UIScreen.main.bounds.width

    //设置主界面顶部的navigation Bar
    var navigationBar = UINavigationBar()
    var navigationView = UIView()
    var navigationTitle = UILabel()
    var navigationDate = UILabel()
    var loadDateAnimation = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: UIColor(named: "TextColor"))
    var date = Int32()
    var navigationMonth = UILabel()
    var seperateLine = UIView()
    var profileButton = UIButton()
    var profileImage = UIView()
    
    
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
    
    /// 在获取内容后刷新tableView的内容
    @objc func reloadData() {
        topStories = readTopStory()
        loadData()
        storeImage()
    }
    
    
    /// 在图像下载完毕后再次刷新
    @objc func reloadTopData() {
        topStories = readTopStory()
        loadData()
        banner.reloadData()
        mainTableView.reloadData()
    }
    
    
    /// 在清除缓存后刷新
    @objc func reloadView() {
        dates = []
        topStories = []
        stories.removeAll()
        topImages = []
        mainTableView.reloadData()
    }
    
    
    /// 在点击头像后跳转登录界面
    @objc func login() {
        let logInPage = LoginController()
        logInPage.modalTransitionStyle = .partialCurl
        logInPage.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        self.present(logInPage, animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
//
        
        super.viewDidLoad()
        
        var bannerHeight = CGFloat() //初始化以作为banner的高度值
        
        if width > 430 {
            bannerHeight = width * 0.8
        } else {
            bannerHeight = 400
        } //机型适配
        
        view.addSubview(mainTableView)
        view.addSubview(navigationBar)
        view.backgroundColor = .systemBackground
        navigationBar.snp.makeConstraints({make -> Void in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
        })
        navigationBar.backgroundColor = .systemBackground
        navigationBar.addSubview(navigationView)
        navigationView.snp.makeConstraints({make -> Void in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        })
        navigationView.addSubview(navigationDate)
        navigationView.addSubview(navigationMonth)
        navigationView.addSubview(loadDateAnimation)
        navigationDate.snp.makeConstraints({make -> Void in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview().offset(6)
            make.height.equalToSuperview()
        })
        navigationMonth.snp.makeConstraints({make -> Void in
            make.centerX.equalTo(navigationDate)
            make.centerY.equalTo(navigationDate).offset(20)
            make.height.equalToSuperview()
        })
        loadDateAnimation.snp.makeConstraints({
            $0.centerY.equalTo(navigationDate).offset(10)
            $0.left.equalToSuperview().offset(18)
            $0.size.equalTo(30)
        })
        // 设置顶部navigationBar的动态布局
        
        date = 0
        loadDateAnimation.startAnimating()
        AF.request("https://news-at.zhihu.com/api/3/news/latest").responseJSON { [self]
            response in
            switch response.result {
            case .success(let json):
                let data = JSON(json)
                self.date = data["date"].int32Value
                var month = Int32()
                if date / 100 % 100 < 10 {
                    month = date / 100 % 100 % 10
                } else {
                    month = date / 100
                }
                switch month {
                case 1:
                    navigationMonth.text = "一月"
                case 2:
                    navigationMonth.text = "二月"
                case 3:
                    navigationMonth.text = "三月"
                case 4:
                    navigationMonth.text = "四月"
                case 5:
                    navigationMonth.text = "五月"
                case 6:
                    navigationMonth.text = "六月"
                case 7:
                    navigationMonth.text = "七月"
                case 8:
                    navigationMonth.text = "八月"
                case 9:
                    navigationMonth.text = "九月"
                case 10:
                    navigationMonth.text = "十月"
                case 11:
                    navigationMonth.text = "十一月"
                case 12:
                    navigationMonth.text = "十二月"
                default:
                    navigationMonth.text = ""
                }
                
                if date % 100 < 10 {
                    navigationDate.text = String((date % 100) % 10)
                } else {
                    navigationDate.text = String((date % 100))
                }
                loadDateAnimation.stopAnimating()
            case .failure(let json):
                print(json.errorDescription!)
                
                let strys = readStory()
                date = strys.min(by: {s1, s2 in s1.date > s2.date })?.date ?? 0
                var month = Int32()
                if date / 100 % 100 < 10 {
                    month = date / 100 % 100 % 10
                } else {
                    month = date / 100
                }
                switch month {
                case 1:
                    navigationMonth.text = "一月"
                case 2:
                    navigationMonth.text = "二月"
                case 3:
                    navigationMonth.text = "三月"
                case 4:
                    navigationMonth.text = "四月"
                case 5:
                    navigationMonth.text = "五月"
                case 6:
                    navigationMonth.text = "六月"
                case 7:
                    navigationMonth.text = "七月"
                case 8:
                    navigationMonth.text = "八月"
                case 9:
                    navigationMonth.text = "九月"
                case 10:
                    navigationMonth.text = "十月"
                case 11:
                    navigationMonth.text = "十一月"
                case 12:
                    navigationMonth.text = "十二月"
                default:
                    navigationMonth.text = ""
                }
                
                if date % 100 < 10 {
                    navigationDate.text = String((date % 100) % 10)
                } else {
                    navigationDate.text = String((date % 100))
                }
                loadDateAnimation.stopAnimating()
            }
        }
        // 刷新左上角的日期
        
        navigationDate.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        navigationMonth.font = UIFont.systemFont(ofSize: 12)
        navigationDate.textColor = UIColor(named: "TextColor")
        navigationMonth.textColor = UIColor(named: "TextColor")
        
        
        navigationView.addSubview(seperateLine)
        seperateLine.snp.makeConstraints({make -> Void in
            make.left.equalToSuperview().offset(60)
            make.centerY.equalTo(navigationDate).offset(10)
            make.width.equalTo(1)
            make.height.equalTo(40)
        })
        seperateLine.backgroundColor = .systemGray
        navigationView.addSubview(navigationTitle)
        navigationTitle.snp.makeConstraints({make -> Void in
            make.left.equalTo(seperateLine).offset(12)
            make.centerY.equalTo(seperateLine)
        })
        navigationTitle.text = "知乎日报"
        navigationTitle.font = UIFont.systemFont(ofSize: 25, weight: .black)
        navigationTitle.textColor = UIColor(named: "TextColor")
        navigationView.addSubview(profileButton)
        profileButton.snp.makeConstraints({make -> Void in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(seperateLine)
            make.size.equalTo(40)
        })
        
        profileButton.setImage(UIImage(named: "profile"), for: .normal)
        profileButton.imageView?.makeViewRoundCorner(2)
        profileButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        
        
        
        
        mainTableView.addSubview(bannerView)
        bannerView.backgroundColor = .systemBackground
        bannerView.addSubview(banner)
        bannerView.addSubview(pageControl)
        bannerView.snp.makeConstraints({make -> Void in
            
            make.width.equalTo(mainTableView)
            make.height.equalTo(bannerHeight)
        })
        banner.snp.makeConstraints({make -> Void in
            
            make.width.equalTo(mainTableView)
            make.height.equalTo(bannerHeight)
        })
        pageControl.snp.makeConstraints({make -> Void in
            make.right.equalToSuperview().offset(-50)
            make.bottom.equalToSuperview().offset(-50)
        })
        banner.delegate = self
        banner.dataSource = self
        banner.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        banner.isInfinite = true
        banner.automaticSlidingInterval = 5
        banner.backgroundColor = .systemBackground
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.setStrokeColor(.systemGray, for: .normal)
        pageControl.setStrokeColor(.systemBackground, for: .selected)
        pageControl.setFillColor(.systemGray, for: .normal)
        pageControl.setFillColor(.systemBackground, for: .selected)
        
        
        do {
            mainTableView.snp.makeConstraints( { make -> Void in
                make.width.equalToSuperview()
                make.height.equalToSuperview().offset(-100)
                make.top.equalTo(navigationBar.snp.bottom)
            })
        }
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .none
//        mainTableView.contentInsetAdjustmentBehavior = .never
        mainTableView.backgroundColor = .systemBackground
////
        writeLatestStory()
        writePreviousStory()
        
                    

        
//            deleteAllStory()
//            deleteAllTop()        
        loadData()
        storeImage()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name(rawValue: "previousLoaded"), object: nil)// 当首页文字内容加载好时进行刷新
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopData), name: Notification.Name(rawValue: "imageLoaded"), object: nil)// 当图片下载好时再次刷新
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: Notification.Name(rawValue: "cacheCleared"), object: nil)// 清除缓存后再次刷新
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadTopData), name: Notification.Name(rawValue: "topLoaded"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloaddata), name: Notification.Name(rawValue: "newspaperLoaded"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataAgain), name: Notification.Name(rawValue: "reloaded"), object: nil)
        
        self.mainTableView.es.addInfiniteScrolling {
            [unowned self] in
            writePreviousStory()
            mainTableView.reloadData()
            self.mainTableView.es.stopLoadingMore()
        } // 设置上拉刷新
    }
}


    
    



extension ViewController: UITableViewDelegate, UITableViewDataSource {

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return stories[keys[section], default: []].count + 1
        } else {
            return stories[keys[section], default: []].count
        }
        
    }
    
    
    /// 设置cell的高度 将第一个cell的高度设置为banner的高度以用于占位
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            if width > 430 {
                return width * 0.8
            } else {
                return 400
            }
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if dates.isEmpty {
            return UIView()
        } else {
            return newHeaderForSection(String(dates[section]), section)
        }
    }
    
    
    /// 设置section的header高度 第一个section没有header，所以将高度设置为0
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
        }else {
            return 40
        }
    }
    
    /// 将footer设置为不显示
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifer = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifer)
        cell?.backgroundColor = .systemBackground
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifer)
        }
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return cell! // 第一列第一个section返回空cell以占位
            } else {
                let index = indexPath.row - 1
                let story = stories[keys[indexPath.section], default: []][index]
                
                cell?.textLabel?.text = story.title
                cell?.textLabel?.numberOfLines = 2
                cell?.textLabel?.textColor = UIColor(named: "TextColor")
                cell?.detailTextLabel?.text = story.hint
                cell?.detailTextLabel?.textColor = .systemGray
                
                let imageView = UIImageView(image: readImage(of: story.id))
                imageView.frame.size = CGSize(width: 70, height: 70)
                imageView.contentMode = .scaleAspectFit
                imageView.makeViewRoundCorner(32)
                cell?.accessoryView = imageView
                return cell!
            }
        } else {
            let story = stories[keys[indexPath.section], default: []][indexPath.row]
            
            cell?.textLabel?.text = story.title
            cell?.textLabel?.numberOfLines = 2
            cell?.textLabel?.textColor = UIColor(named: "TextColor")
            cell?.detailTextLabel?.text = story.hint
            cell?.detailTextLabel?.textColor = .systemGray
            
            let imageView = UIImageView(image: readImage(of: story.id))
            imageView.frame.size = CGSize(width: 70, height: 70)
            imageView.contentMode = .scaleAspectFit
            imageView.makeViewRoundCorner(32)
            cell?.accessoryView = imageView
            return cell!
        }
        
    }
    
    
    /// 设置点击跳转故事详情页
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
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
            } else {
                let index = indexPath.row - 1
                let story = stories[keys[indexPath.section], default: []][index]
                detailPage.id = story.id
                for key in keys {
                    for id in stories[key] ?? [] {
                        detailPage.ids.append(id.id)
                    }
                }
                
                self.present(detailPage, animated: false, completion: nil)
            }
        } else {
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
    
}

extension ViewController: FSPagerViewDelegate, FSPagerViewDataSource {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 5
    }

    
    /// 设置banner的内容
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.backgroundColor = .systemBackground
        
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
        imageView.image = topImages.isEmpty ? UIImage(named: "white") : topImages[index]
        hint.text = topHints.isEmpty ? "" : topHints[index]
        title.text = topHints.isEmpty ? "" : topTitles[index]
        imageView.snp.makeConstraints({make -> Void in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        })


        hint.textColor = .systemGray
        title.textColor = UIColor(named: "bannerColor")
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
    
    /// 设置点击banner跳转详情页
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
    
    func loadData() {
        //      将CoreData中date的值存入集合中，以获得无重复的日期值
                var groups = Set<Int32>()
                for story in readStory() {
                    groups.insert(story.date)
                }
                keys = groups.sorted(by: >)
                //将CoreData中的元素按相同日期归至同一数组
                    
                
        //      向浏览列表的数组填充数据
                if stories.isEmpty {
                    readStory().forEach { story in
                        stories[story.date, default: []].append(story)
                    }
                } else {
                    var storiesToBeUpdate = [Story]()
                    for story in readStory() {
                        if !stories.keys.contains(story.date) {
                            storiesToBeUpdate.append(story)
                        }
                    }
                    for story in storiesToBeUpdate {
                        stories[story.date] = []
                    }
                    for story in storiesToBeUpdate {
                        stories[story.date]?.append(story)
                    }
                }
                
                
                
        //        向banner的数组填充数据
                for TopStory in topStories {
                   if let image = readImage(of: TopStory.id) {
                    if topImages.count < 5 {
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
                
        //        向header的日期数组中填充数据
                for key in keys {
                   var month,date: String
                   let monthNumber = key / 100 % 100
                   if monthNumber < 10{
                       month = String(monthNumber % 10)
                   } else {
                       month = String(monthNumber)
                   }
                   let dateNumber = key % 100
                   if dateNumber < 10 {
                       date = String(dateNumber % 10)
                   } else {
                       date = String(dateNumber)
                   }
                    if !dates.contains("\(month)月\(date)日") {
                        dates.append("\(month)月\(date)日")
                    }
               }
    }
    
    
    /// 将图片以Story的id.jpg为文件名进行存储
    func storeImage() {
        for story in readStory() {
            let imageView = UIImageView()
            if let link = story.image {
                imageView.downloadedFrom(link: link)
            }else {
                print("imageUrlin storie is empty")
            }
            _ = URLRequest(url: URL(string: story.image ?? "emptyLink")!)
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(story.id).jpg")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            AF.download(story.image ?? "empty", to: destination).downloadProgress { progress in
                if progress.isFinished {
                }
            }.responseData(completionHandler: { _ in})
        }
        for topStory in readTopStory() {
            _ = URLRequest(url: URL(string: topStory.image ?? "emptyLink")!)
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(topStory.id).jpg")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            AF.download(topStory.image ?? "empty", to: destination).downloadProgress { progress in
                if progress.isFinished {
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        print(self.topImages)
                        if readTopStory().last == topStory && readTopStory().count == 5 {
                            postNotification("imageLoaded")
                            print("图片存了\(self.topImages)")
                        }
                    }
                }
            }.responseData(completionHandler: { _ in})
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
    
    
    
    /// 设置各个section之间的日期和分割线
    /// - Parameters:
    ///   - date: 当前section的日期
    ///   - section: seciton
    func newHeaderForSection(_ date: String, _ section :Int) -> UIView {
        if section == 0 {
            return bannerView
        }else {
            let backView = UIView()
            backView.backgroundColor = .systemBackground
            let line = UIView()
            backView.addSubview(line)
            line.backgroundColor = .lightGray
            line.snp.makeConstraints({make -> Void in
                make.center.equalToSuperview()
                make.height.equalTo(0.5)
                make.right.equalToSuperview()
                make.left.equalToSuperview().offset(80)
            })
            let textView = UIButton()
            backView.addSubview(textView)
            textView.setTitle(date, for: .normal)
            textView.setTitleColor(.gray, for: .normal)
            textView.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            textView.backgroundColor = .systemBackground
            textView.snp.makeConstraints({make -> Void in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
                make.width.equalTo(80)
                make.height.equalTo(10)
            })
            print("日期是\(section)")
            return backView
        }
        
    }
    
    

}

extension UIView {
    
    /// 将UIView进行圆角处理
    func makeViewRoundCorner(_ rate: CGFloat) {
        layer.cornerRadius = frame.width / rate
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





