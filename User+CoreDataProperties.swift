//
//  User+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/1/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var password: String?

}

extension User : Identifiable {

}
