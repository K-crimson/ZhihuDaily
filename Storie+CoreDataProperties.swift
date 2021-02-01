//
//  Storie+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/1/31.
//
//

import Foundation
import CoreData


extension Storie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Storie> {
        return NSFetchRequest<Storie>(entityName: "Storie")
    }

    @NSManaged public var date: Int32
    @NSManaged public var hint: String?
    @NSManaged public var id: Int32
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}

extension Storie : Identifiable {

}
