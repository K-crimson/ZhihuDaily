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
    var dates = [String]()
    var topStories = [TopStory]()
    
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
        mainTableView.separatorStyle = .none
        writeLatestStory()
//        writePreviousStory()
//        deleteAllStory()
        storeImage()
        for top in readTopStory() {
            print(top.title)
        }

       
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
//        for key in keys[1..<keys.count]
        for key in keys {
            var month,date: String
            month = String((key/100)%10)
            date = String(key%10)
            dates.append("\(month)月\(date)日")
        }
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
        100
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return newHeaderForSection(String(dates[section]), section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
            /// attention 此处存储图片使用了延时执行 使图片在进行保存前下载成功 后续需改进
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                let image = imageView.image
                var documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                documentsPath.appendPathComponent("\(story.id).jpg")
                let data = image!.jpegData(compressionQuality: 1.0)
                FileManager.default.createFile(atPath: documentsPath.path, contents: data, attributes: nil)
            }
        }
        for TopStory in readTopStory() {
            var imageView = UIImageView()
            if let link = TopStory.image {
                imageView.downloadedFrom(link: "\(link)")
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
        let backView = UIView()
        backView.backgroundColor = UIColor.white
//        backView.snp.makeConstraints({make -> Void in
//            make.height.equalTo(10)
//        })
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
        
        if section == 0 {
            backView.isHidden = true
        }
        return backView
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

extension ViewController : UIScrollViewDelegate {
    
    /// 将UItableView在plain模式下取消悬浮
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainTableView {
            let sectionHeaderHeight = CGFloat(40)//headerView的高度
            if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {

                scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0);

            } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {

                scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight - 150, left: 0, bottom: 0, right: 0);
            }

        }
    }
}

//class BannerView: UIView, UIScrollViewDelegate {
//    // 图⽚⽔平放置到scrollView上
//    private var scrollView = UIScrollView()
//    // ⼩圆点标识
//    private var pageControl = UIPageControl()
//    private var imageViews = [UIImageView]()
// 
//    // 图⽚集合
//    private var images: [String] = []
//    private var type: ImageType?
// 
//    private var width: CGFloat = 0
//    private var height: CGFloat = 0
// 
//    private var currIndex = 0
//    private var clickBlock: (Int) -> Void = { _ in }
// 
//    private var timer: Timer?
// 
//    // 默认⾃动播放 设置为false只能⼿动滑动
//    var isAuto = true
//    // 轮播间隔时间 默认6秒可以⾃⼰修改
//    var interval: Double = 6
// 
//    private var startOffsetX: CGFloat = 0
// 
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
// 
//    public func setImages(images: [String], type: ImageType
//        = .Image, imageClickBlock: @escaping (Int) -> Void)
//    {
//        self.type = type
//        self.images = images
//        self.clickBlock = imageClickBlock
//        self.initLayout()
//    }
// 
//    private func initLayout() {
//        if self.images.count == 0 {
//            return
//        }
// 
//        width = self.bounds.width
//        height = self.bounds.height
// 
//        scrollView.frame = self.bounds
//        scrollView.contentSize = CGSize(width: width * CGFloat(images.count +
//                2), height: height)
//        scrollView.contentOffset = CGPoint(x: width, y: 0)
//        scrollView.isUserInteractionEnabled = true
//        scrollView.isPagingEnabled = true
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.delegate = self
//        self.addSubview(scrollView)
// 
//        var image = UIImageView()
//        image.frame = CGRect(x: 0, y: 0, width: width, height: height)
//        image.contentMode = .scaleToFill
//        image.isUserInteractionEnabled = true
//        setImage(image: image, index: images.count - 1)
//        scrollView.addSubview(image)
//        for i in 1 ... images.count {
//            let image = UIImageView()
//            image.frame = CGRect(x: width *
//                CGFloat(i), y: 0, width: width, height: height)
//            image.contentMode = .scaleToFill
//            image.isUserInteractionEnabled = true
//            scrollView.addSubview(image)
//            setImage(image: image, index: i - 1)
//            addTapGesWithImage(image: image)
//        }
//        image = UIImageView()
//        image.frame = CGRect(x: width * CGFloat(images.count +
//                1), y: 0, width: width, height: height)
//        image.contentMode = .scaleToFill
//        image.isUserInteractionEnabled = true
//        scrollView.addSubview(image)
//        setImage(image: image, index: 0)
// 
//        pageControl.center = CGPoint(x: width / 2, y: height - CGFloat(15))
//        pageControl.isEnabled = true
//        pageControl.numberOfPages = images.count
//        pageControl.currentPageIndicatorTintColor = UIColor.green
//        pageControl.pageIndicatorTintColor = UIColor.gray
//        pageControl.isUserInteractionEnabled = false
//        self.addSubview(pageControl)
//        if isAuto {
//            openTimer()
//        }
//        setCurrent(currIndex: 0)
//    }
// 
//    private func setImage(image: UIImageView, index: Int) {
//        if type == .Image {
//            image.image = UIImage(named: images[index])
//        } else {
////            image.setMyImage(url: images[index])
//            
//        }
//    }
// 
//    func setCurrent(currIndex: Int) {
//        if currIndex < 0 {
//            self.currIndex = images.count - 1
//        } else {
//            self.currIndex = currIndex
//        }
//        pageControl.currentPage = self.currIndex
//        scrollView.setContentOffset(CGPoint(x: width * CGFloat(self.currIndex +
//                1), y: 0), animated: false)
//    }
// 
//    // 给图⽚添加点击⼿势
//    private func addTapGesWithImage(image: UIImageView) {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
//        image.isUserInteractionEnabled = true // 让控件可以触发交互事件
//        image.contentMode = .scaleToFill
//        // image.clipsToBounds = true //超出⽗控件的部分不显示
//        image.addGestureRecognizer(tap)
//    }
// 
//    // 点击图⽚，调⽤block
//    @objc func tap(_ ges: UITapGestureRecognizer) {
//        clickBlock((ges.view?.tag)!)
//    }
// 
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
// 
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        startOffsetX = scrollView.contentOffset.x
//        closeTimer()
//    }
// 
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
// 
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x > startOffsetX {
//            currIndex = (currIndex + 1) % images.count
//        } else {
//            currIndex = (currIndex - 1) % images.count
//        }
//        setCurrent(currIndex: currIndex)
//        openTimer()
//    }
// 
//    func openTimer() {
//        if isAuto {
//            closeTimer()
//            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector:
//                #selector(startAutoScroll), userInfo: nil, repeats: true)
//        }
//    }
// 
//    func closeTimer() {
//        if timer != nil {
//            timer?.invalidate()
//            timer = nil
//        }
//    }
// 
//    @objc func startAutoScroll() {
//        if isDisplayInScreen() {
//            setCurrent(currIndex: (currIndex + 1) % images.count)
//        }
//    }
// 
//    func isDisplayInScreen() -> Bool {
//        if self.window == nil {
//            return false
//        }
//        return true
//    }
//}
//
//enum ImageType {
//    case Image // 本地图⽚
//    case URL // URL
//}
