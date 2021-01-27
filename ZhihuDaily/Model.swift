//
//  Model.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/1/24.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData


class Storie {
    var title = String()
    var ga_prefix = String()
    var images = [String]()
    var id = Int()
}

class Top_Stories {
    var title = String()
    var ga_prefix = String()
    var images = [String]()
    var id = Int()
}

class test {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var  managedObjectContext = appDelegate.persistentContainer.viewContext
}

