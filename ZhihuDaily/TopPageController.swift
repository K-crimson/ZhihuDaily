//
//  TopPageController.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/2/24.
//

import Foundation
import UIKit
import SnapKit
import Alamofire
import SwiftyJSON
import CoreData
import FSPagerView
import WebKit

class TopController: UIViewController {
    var id = Int32()
    var ids = [Int32]()
    var TopPages = [WKWebView]()
    lazy var readView :FSPagerView = {
        return FSPagerView()
    }()
    lazy var readControl: FSPageControl = {
        return FSPageControl()
    }()

    var bottomBar = UIView()
    let backButton = UIButton()
    let line = UIView()
    let comments = BottomButton()
    let commentsNumber = UILabel()
    let like = BottomButton()
    let likesNumber = LikeNumber()
    let star = BottomButton()
    let share = UIButton()




    let detailPage = UIView()
    let config = WKWebViewConfiguration()

    var Urls = [URL]()
//    var ids = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPage()
        view.addSubview(detailPage)
        detailPage.snp.makeConstraints({make -> Void in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        })
        detailPage.backgroundColor = .white
        detailPage.addSubview(bottomBar)
        bottomBar.backgroundColor = .systemBackground
        bottomBar.snp.makeConstraints({make -> Void in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(70)
        })

        let width = UIScreen.main.bounds.width

        detailPage.addSubview(readView)

        readView.snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.bottom.equalTo(bottomBar.snp.top)
            $0.top.equalToSuperview()
        })

        readView.delegate = self
        readView.dataSource = self
        readView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "readView")
        readView.isInfinite = true

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        bottomBar.addSubview(backButton)
        backButton.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(bottomBar.snp.left).offset(width/11)
            make.size.equalTo(bottomBar.snp.height)
        })
        backButton.tintColor = UIColor(named: "TextColor")
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        bottomBar.addSubview(line)
        line.backgroundColor = .systemGray
        line.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(bottomBar.snp.left).offset(width / 6)
            make.height.equalToSuperview().offset(-30)
            make.width.equalTo(1)
        })


        comments.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        bottomBar.addSubview(comments)
        comments.tintColor = UIColor(named: "TextColor")
        comments.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(bottomBar.snp.left).offset(width / 4.6)
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
        commentsNumber.tintColor = UIColor(named: "TextColor")


        like.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        bottomBar.addSubview(like)
        like.tintColor = UIColor(named: "TextColor")
        like.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(bottomBar.snp.left).offset(width / 2.5)
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
        likesNumber.tintColor = UIColor(named: "TextColor")

        star.setImage(UIImage(systemName: "star"), for: .normal)
        bottomBar.addSubview(star)
        star.tintColor = UIColor(named: "TextColor")
        star.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(bottomBar.snp.centerX).offset(width / 12)
            make.size.equalTo(bottomBar.snp.height)
        })
        star.addTarget(self, action: #selector(addStar(_:)), for: .touchUpInside)




        share.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        bottomBar.addSubview(share)
        share.tintColor = UIColor(named: "TextColor")
        share.snp.makeConstraints({make -> Void in
            make.centerY.equalToSuperview()
            make.left.equalTo(bottomBar.snp.centerX).offset(width / 3.7)
            make.size.equalTo(bottomBar.snp.height)
        })
    }

}



extension TopController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        for webPage in TopPages {
            webPage.evaluateJavaScript("document.getElementsByClassName('ZhihuDailyOIABanner')[0].style.display = 'none'", completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                webPage.isHidden = false
            }
        }
        webView.configuration.preferences.javaScriptEnabled = false
    }


}


extension TopController {
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
            button.tintColor = UIColor(named: "TextColor")
            likesNumber.number -= 1
            likesNumber.textColor = UIColor(named: "TextColor")
            self.view.makeToast("取消点赞", duration: 2.0, position: .center)
        } else if button.isClicked{
            button.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            button.tintColor = .systemBlue
            likesNumber.number += 1
            likesNumber.textColor = .systemBlue
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
            button.tintColor = .systemBlue
            self.view.makeToast("收藏成功", duration: 2.0, position: .center)

        }
    }

    func loadPage() {
        let position = ids.firstIndex(of: id) ?? 0
        let adjust = ids[position...4]
        ids.removeLast(5 - position)
        ids.insert(contentsOf: adjust, at: 0)
        
        
        for x in 0...4 {
            
            let page = WKWebView()
            let url = URL(string: "https://daily.zhihu.com/story/\(ids[x] - 10000000)")!
            let request = URLRequest(url: url)
            page.load(request)
            TopPages.append(page)
            page.navigationDelegate = self
            page.isHidden = true
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
                print(json.errorDescription!)
            }
        }
    }
    func removeHeader() {
        for webPage in TopPages {
            webPage.evaluateJavaScript("document.getElementsByClassName('ZhihuDailyOIABanner')[0].style.display = 'none'", completionHandler: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                webPage.isHidden = false
            }
        }
    }
}


extension TopController: FSPagerViewDelegate,FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 5
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "readView", at: index)
        cell.contentView.addSubview(TopPages[index])
        TopPages[index].snp.makeConstraints({
            $0.width.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalToSuperview()
        })
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        removeHeader()
    }

    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
    }
}
