//
//  Story+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/2/6.
//
//

import Foundation
import CoreData


extension Story {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Story> {
        return NSFetchRequest<Story>(entityName: "Story")
    }

    @NSManaged public var date: Int32
    @NSManaged public var hint: String?
    @NSManaged public var id: Int32
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}

extension Story : Identifiable {

}
