//
//  User+CoreDataProperties.swift
//  
//
//  Created by yulin on 2021/10/30.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userId: String?
    @NSManaged public var userName: NSObject?
    @NSManaged public var petsIds: NSObject?

}
