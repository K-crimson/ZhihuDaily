//
//  Account+CoreDataProperties.swift
//  ZhihuDaily
//
//  Created by 车致远 on 2021/3/26.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var logStatus: Bool

}

extension Account : Identifiable {

}
