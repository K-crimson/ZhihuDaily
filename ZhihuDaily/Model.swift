//
//  Model.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/1/24.
//

import Alamofire
import CoreData
import Foundation
import SwiftyJSON





/// 读取Coredata中的数据
/// - Returns: 返回数组形式的Story
func readStory() -> [Story] {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    
    let entity: NSEntityDescription? =
        NSEntityDescription.entity(forEntityName: "Story", in: managedObjectContext)
    let request = NSFetchRequest<Story>(entityName: "Story")
    var result: [AnyObject]?
    request.fetchOffset = 0
    request.entity = entity
    result = try! managedObjectContext.fetch(request)
    let temp = result as! [Story]
    return temp
}

func readTopStory() -> [TopStory] {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    
    let entity: NSEntityDescription? =
        NSEntityDescription.entity(forEntityName: "TopStory", in: managedObjectContext)
    let request = NSFetchRequest<TopStory>(entityName: "TopStory")
    var result: [AnyObject]?
    request.fetchOffset = 0
    request.entity = entity
    result = try! managedObjectContext.fetch(request)
    let temp = result as! [TopStory]
    return temp
}


/// 获取当天的Story并存储至CoreData
func writeLatestStory () {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    
    
    AF.request("https://news-at.zhihu.com/api/3/news/latest").responseJSON {
        response in
        switch response.result {
        case .success(let json):
            
            let data = JSON(json)
            var date = data["date"].int32Value
            print(date)
            var hasBeenAdded = false
            for story in readStory() {
                if story.date == date {
                    hasBeenAdded = true
                }
            }
            if !hasBeenAdded {
                let stories = data["stories"].arrayValue
                for story in stories {
                    let newStory = NSEntityDescription.insertNewObject(forEntityName: "Story", into: managedObjectContext) as! Story
                    
                    newStory.date = date
                    newStory.hint = story["hint"].stringValue
                    newStory.id = story["id"].int32Value
                    newStory.title = story["title"].stringValue
                    newStory.url = story["url"].stringValue
//                    if let images = story["images"].array {
//                        newStory.image = images[0].stringValue
//                    }
                    if let image = story["images"].arrayValue.first {
                        newStory.image = image.stringValue
                    }
                    
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print("\(error)")
                    }
                }
            }
            deleteAllTop()
            let topstories = data["top_stories"].arrayValue
            for topstory in topstories {
                let newTopStory = NSEntityDescription.insertNewObject(forEntityName: "TopStory", into: managedObjectContext) as! TopStory
                newTopStory.title = topstory["title"].stringValue
                newTopStory.image = topstory["image"].stringValue
                newTopStory.url = topstory["url"].stringValue
                newTopStory.hint = topstory["hint"].stringValue
                newTopStory.id = topstory["id"].int32Value + 10000000
                do {
                    try managedObjectContext.save()
                } catch {
                    print("\(error)")
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newstoryLoaded"), object: nil, userInfo: nil)
            
        case .failure(let json):
            print(json.errorDescription)
        }
        
        

    }
    
    do {
        try managedObjectContext.save()
    } catch {
        print("\(error)")
    }
    
    
}

/// 获取先前的Story并存储至CoreData
func writePreviousStory () { //
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
   let managedObjectContext = appDelegate.persistentContainer.viewContext

   var dates = [Int32]()
   for storys in readStory() {
       dates.append(storys.date)
   }
   var previousDate = String()
   if let datesMin = dates.min() {
       previousDate = String(datesMin)
   } else {
       print("storysDate is empty")
   }
   print("previousdate is \(previousDate)")
   AF.request("https://news-at.zhihu.com/api/3/stories/before/\(previousDate)").responseJSON {
       response in
       switch response.result {
       case .success(let json):
           let data = JSON(json)
           var date = data["date"].int32Value
           var hasBeenAdded = false
           for story in readStory() {
               if story.date == date {
                   hasBeenAdded = true
               }
           }
           
           if !hasBeenAdded {
               let stories = data["stories"].arrayValue
               for story in stories {
                   let newStory = NSEntityDescription.insertNewObject(forEntityName: "Story", into: managedObjectContext) as! Story
                   newStory.date = date
                   newStory.hint = story["hint"].stringValue
                   newStory.id = story["id"].int32Value
                   newStory.title = story["title"].stringValue
                   newStory.url = story["url"].stringValue
                    if let image = story["images"].arrayValue.first {
                        newStory.image = image.stringValue
                    }
                   do {
                       try managedObjectContext.save()
                   } catch {
                       print("\(error)")
                   }
               }
           }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "newspaperLoaded"), object: nil, userInfo: nil)
       case .failure(let json):
           print(json.errorDescription)
       }
       

   }
}


func deleteAllStory() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    
    let entity: NSEntityDescription? =
        NSEntityDescription.entity(forEntityName: "Story", in: managedObjectContext)
    let request = NSFetchRequest<Story>(entityName: "Story")
    request.fetchOffset = 0
    request.entity = entity
    do {
        let results: [AnyObject]? = try managedObjectContext.fetch(request)
        for story: Story in results as! [Story]{
            managedObjectContext.delete(story)
        }
        try managedObjectContext.save()
        let _:[AnyObject]? = try managedObjectContext.fetch(request)
    } catch {
        let error = error as NSError
    }
    
}

func deleteAllTop() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    
    
    let entity: NSEntityDescription? =
        NSEntityDescription.entity(forEntityName: "TopStory", in: managedObjectContext)
    let request = NSFetchRequest<TopStory>(entityName: "TopStory")
    request.fetchOffset = 0
    request.entity = entity
    do{
        let results:[AnyObject]? = try managedObjectContext.fetch(request)
        for story: TopStory in results as! [TopStory]{
            managedObjectContext.delete(story)
        }
        try managedObjectContext.save()
        let _:[AnyObject]? = try managedObjectContext.fetch(request)
    } catch {
        let error = error as NSError
        print(error)
    }
    
}






