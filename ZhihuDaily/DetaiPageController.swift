//
//  DetaiPageController.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/2/11.
//

import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import CoreData
import FSPagerView
import WebKit
import Toast_Swift

/// 详情页底部的按钮
class BottomButton: UIButton{
    var isClicked = false
}


/// 详情页底部点赞按钮的点赞数
class LikeNumber: UILabel {
    var isClicked = false
    var number = 3 {
        didSet {
            text = number.description
        }
    }
}


class DetailController: UIViewController {
    var id = Int32()
    var ids = [Int32]()
    var idPosition = 0
    var first = Bool()
    var formerAction = String()

    lazy var readView :FSPagerView = {
        return FSPagerView()
    }()
    lazy var readControl: FSPageControl = {
        return FSPageControl()
    }()
    
    var webPage0: WKWebView = {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let result = WKWebView(frame: .zero, configuration: configuration)
        return result
    }()
    var webPage1: WKWebView = {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let result = WKWebView(frame: .zero, configuration: configuration)
        return result
    }()
    var webPage2: WKWebView = {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let result = WKWebView(frame: .zero, configuration: configuration)
        return result
    }()
    var webPage3: WKWebView = {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        let result = WKWebView(frame: .zero, configuration: configuration)
        return result
    }()
    var webPages = [WKWebView]()
    var currentPage = 0
    var formerPage = 0
    let commentsNumber = UILabel()

    
    
    var bottomBar = UIView()
    let backButton = UIButton()
    let line = UIView()
    let comments = BottomButton()
    let like = BottomButton()
    let star = BottomButton()
    let share = UIButton()



    
    let detailPage = UIView()
    let config = WKWebViewConfiguration()
    
    let likesNumber = LikeNumber()
    
    var Urls = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        readIds()
        first = true
        idPosition = ids.firstIndex(of: id) ?? 0
//        print(id)
        
        webPages.append(webPage0)
        webPages.append(webPage1)
        webPages.append(webPage2)
        webPage0.navigationDelegate = self
        webPage1.navigationDelegate = self
        webPage2.navigationDelegate = self
        webPages[0].isHidden = true
        let originalId = id
        loadPage(originalId)
        view.addSubview(detailPage)
        detailPage.snp.makeConstraints({make -> Void in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        })
        detailPage.backgroundColor = .white
        
        
        
        
        
        
        
        
        
        
        
        detailPage.addSubview(bottomBar)
        bottomBar.snp.makeConstraints({make -> Void in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(70)
        })
        
        
        detailPage.addSubview(readView)
        
        readView.snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top)
            $0.top.equalToSuperview()
        })
        
        readView.delegate = self
        readView.dataSource = self
        readView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "TopView")
        readView.isInfinite = true
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        bottomBar.addSubview(backButton)
        backButton.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.size.equalTo(bottomBar.snp.height)
        })
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        bottomBar.addSubview(line)
        line.backgroundColor = .gray
        line.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(backButton.snp.right)
            make.height.equalToSuperview().offset(-30)
            make.width.equalTo(1)
        })


        comments.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        bottomBar.addSubview(comments)
        comments.tintColor = .black
        comments.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(line.snp.right)
            make.size.equalTo(bottomBar.snp.height)
        })


        bottomBar.addSubview(commentsNumber)
        commentsNumber.snp.makeConstraints({make -> Void in
            make.centerX.equalTo(comments).offset(19)
            make.centerY.equalTo(comments).offset(-10)
            make.size.equalTo(20)
        })
        commentsNumber.text = "3"
        commentsNumber.font = UIFont.systemFont(ofSize: 10)
        commentsNumber.tintColor = .black


        like.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        bottomBar.addSubview(like)
        like.tintColor = .black
        like.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(comments.snp.right)
            make.size.equalTo(bottomBar.snp.height)
        })
        like.addTarget(self, action: #selector(addLike(_:)), for: .touchUpInside)

        bottomBar.addSubview(likesNumber)
        likesNumber.snp.makeConstraints({make -> Void in
            make.centerX.equalTo(like).offset(15)
            make.centerY.equalTo(like).offset(-10)
            make.size.equalTo(20)
        })
        likesNumber.number = 8
        likesNumber.font = UIFont.systemFont(ofSize: 8)
        likesNumber.tintColor = .black

        star.setImage(UIImage(systemName: "star"), for: .normal)
        bottomBar.addSubview(star)
        star.tintColor = .black
        star.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(like.snp.right)
            make.size.equalTo(bottomBar.snp.height)
        })
        star.addTarget(self, action: #selector(addStar(_:)), for: .touchUpInside)




        share.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        bottomBar.addSubview(share)
        share.tintColor = .black
        share.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(bottomBar.snp.height)
        })
    }
        
}



extension DetailController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        for webPage in webPages {
            webPage.evaluateJavaScript("document.getElementsByClassName('ZhihuDailyOIABanner')[0].style.display = 'none'", completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                webPage.isHidden = false
            }
        }
        webView.configuration.preferences.javaScriptEnabled = false
    }
    
    
}



extension DetailController: UINavigationBarDelegate {

}

extension DetailController {
    @objc func back() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    @objc func addLike(_ button: BottomButton) {
        button.isClicked.toggle()
        if !button.isClicked {
            button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            button.tintColor = .black
            likesNumber.number -= 1
            likesNumber.textColor = .black
            self.view.makeToast("取消点赞", duration: 2.0, position: .center)
        } else if button.isClicked{
            button.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            button.tintColor = .blue
            likesNumber.number += 1
            likesNumber.textColor = .blue
            self.view.makeToast("点赞成功", duration: 2.0, position: .center)
        }
    }
    
    @objc func addStar(_ button: BottomButton) {
        button.isClicked.toggle()
        if button.isClicked == false {
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .black
            self.view.makeToast("取消收藏", duration: 2.0, position: .center)
        } else if button.isClicked == true{
            button.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button.tintColor = .blue
            self.view.makeToast("收藏成功", duration: 2.0, position: .center)
        }
    }
    
    func loadPage(_ id: Int32) {
        var url0 = URL(string: "aaa")!
        var url1 = URL(string: "aaa")!
        var url2 = URL(string: "aaa")!
        if idPosition == 0 {
            url0 = URL(string: "https://daily.zhihu.com/story/\(id)")!
            url1 = URL(string: "https://daily.zhihu.com/story/\(ids[idPosition + 1])")!
            url2 = URL(string: "https://daily.zhihu.com/story/\(ids[idPosition + 2])")!
        } else {
            url0 = URL(string: "https://daily.zhihu.com/story/\(id)")!
            url1 = URL(string: "https://daily.zhihu.com/story/\(ids[idPosition + 1])")!
            url2 = URL(string: "https://daily.zhihu.com/story/\(ids[idPosition - 1])")!
        }
//        url0 = URL(string: "https://daily.zhihu.com/story/\(id)")!
//        url1 = URL(string: "https://daily.zhihu.com/story/\(ids[idPosition + 1])")!
//        url2 = URL(string: "https://daily.zhihu.com/story/\(ids[idPosition - 1])")!
        let requst0 = URLRequest(url: url0)
        webPage0.load(requst0)
        let requst1 = URLRequest(url: url1)
        webPage1.load(requst1)
        let requst2 = URLRequest(url: url2)
        webPage2.load(requst2)
        downloadCommentsNumber(id)
    }
    
//    TODO: 将复用机制中代码精简
//    func loadNewPage(_ id:Int32) {
//        let webPage = WKWebView()
//        webPage.loadPage(id)
//        webPage.navigationDelegate = self
//    }
    
    
    func readIds() {
        for stories in readStory() {
            ids.append(stories.id)
        }
    }
    
    func removeHeader() {
        for webPage in webPages {
            webPage.evaluateJavaScript("document.getElementsByClassName('ZhihuDailyOIABanner')[0].style.display = 'none'", completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                webPage.isHidden = false
            }
        }	    
    }
    
    func downloadCommentsNumber(_ storyID: Int32) {
        AF.request("https://news-at.zhihu.com/api/3/story-extra/\(storyID)").responseJSON {
            response in
            switch response.result {
            case .success(let json):
                let data = JSON(json)
                let comments = data["comments"].stringValue
                let likes = data["popularity"].intValue
                self.likesNumber.number = likes
                self.commentsNumber.text = comments
            case .failure(let json):
                print(json.errorDescription ?? "")
            }
        }
    }
}

extension BottomButton {
    
}

extension DetailController: FSPagerViewDelegate,FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "TopView", at: index)
        cell.contentView.addSubview(webPages[index])
        webPages[index].snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalToSuperview()
        })
        currentPage = index
        removeHeader()
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
//        webPages[index].isHidden = false
//        print(index)
//        print("is\(index - formerPage)")
        var right = Bool()
        var flip = Bool()
        if index == currentPage {
            print("didintflip")
            flip = false
        } else if index != currentPage {
//            print("flip")
//            print(currentPage - index)
            flip = true
            if currentPage - index == 1 || currentPage - index == -2 {
                print("right")
                right = true
            } else if currentPage - index == -1 || currentPage - index == 2 {
                print("left")
                right = false
            }
        }
//
        if flip {
            if right {
                if index == 0 {
                    if first  {
                        id = ids[(ids.firstIndex(of: id) ?? 0) + 2]
                        let webPage = WKWebView()
                        webPage.loadPage(id)
                        webPage.navigationDelegate = self
                        webPages[2] = webPage
                        first = false
                    }else if first == false && formerAction != "left" {
                        id = ids[(ids.firstIndex(of: id) ?? 0) + 1]
                        print("a\(id)")
                        let webPage = WKWebView()
                        webPage.navigationDelegate = self
                        webPage.loadPage(id)
                        webPages[2] = webPage
                    } else if formerAction == "left" {
                        if ids.firstIndex(of: id) == 2{
                            id = ids[(ids.firstIndex(of: id) ?? 0)]
                        } else {
                            id = ids[(ids.firstIndex(of: id) ?? 0) + 3]

                        }
                        let webPage = WKWebView()
                        webPage.loadPage(id)
                        webPage.navigationDelegate = self
                        webPages[2] = webPage
                    }
                } else if index == 1 {
                    if formerAction == "left" {
                        id = ids[(ids.firstIndex(of: id) ?? 0) + 3]
                        let webPage = WKWebView()
                        webPage.loadPage(id)
                        webPage.navigationDelegate = self
                        webPages[0] = webPage
                    } else {
                        id = ids[(ids.firstIndex(of: id) ?? 0) + 1]
                        print(id)

                        let webPage = WKWebView()
                        webPage.loadPage(id)
                        webPage.navigationDelegate = self
                        webPages[0] = webPage
                    }
                        
                    } else if index == 2 {
                        if formerAction == "left" {
                            id = ids[(ids.firstIndex(of: id) ?? 0) + 3]
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[1] = webPage
                        } else {
                            id = ids[(ids.firstIndex(of: id) ?? 0) + 1]
                            print(id)
                            var webPage = WKWebView()
                            webPage.navigationDelegate = self
                            webPage.loadPage(id)
                            webPages[1] = webPage
                        }

                    }
                
                formerAction = "right"
            }
            if !right {
                if ids.firstIndex(of: id) == 0 {
                } else {
                    if index == 0 {
                        if first {
                            if ids.firstIndex(of: id) == 1 {
                                id = ids[(ids.firstIndex(of: id) ?? 0) - 1]
                            } else {
                                id = ids[(ids.firstIndex(of: id) ?? 0) - 2]
                            }
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[1] = webPage
                            first = false
                        } else if first == false {
                            id = ids[(ids.firstIndex(of: id) ?? 0) - 1]
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[1] = webPage
                        } else if formerAction == "right" {
                            id = ids[(ids.firstIndex(of: id) ?? 0) - 3]
                            print("first\(id)")
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[1] = webPage
                        }
                    } else if index == 1 {
                        if formerAction == "right" {
                            if ids.firstIndex(of: id) == 2 {
//                                id = ids[(ids.firstIndex(of: id) ?? 0) + 1]
                                
                            } else {
                                id = ids[(ids.firstIndex(of: id) ?? 0) - 3]
                            }
                            print(id)
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[2] = webPage
                        } else {
                            id = ids[(ids.firstIndex(of: id) ?? 0) - 1]
                            print(id)
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[2] = webPage
                        }
                        
                    } else if index == 2 {
                        if formerAction == "right" {
                            id = ids[(ids.firstIndex(of: id) ?? 0) - 3]
                            print(id)
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[0] = webPage
                        } else {
                            id = ids[(ids.firstIndex(of: id) ?? 0) - 1]
                            print(id)
                            var webPage = WKWebView()
                            webPage.loadPage(id)
                            webPage.navigationDelegate = self
                            webPages[0] = webPage
                        }
                        
                    }
                }
                formerAction = "left"
            }
            removeHeader()
            downloadCommentsNumber(id)
        }
        print("end\(index)")
        formerPage = index
    }
}

extension WKWebView {
    func loadPage(_ id: Int32) {
        let url = URL(string: "https://daily.zhihu.com/story/\(id)")!
        let request = URLRequest(url: url)
        self.load(request)
        self.isHidden = true
    }
}
