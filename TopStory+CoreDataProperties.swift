//
//  TopStory+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/2/10.
//
//

import Foundation
import CoreData


extension TopStory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopStory> {
        return NSFetchRequest<TopStory>(entityName: "TopStory")
    }

    @NSManaged public var id: Int32
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var hint: String?

}

extension TopStory : Identifiable {

}
