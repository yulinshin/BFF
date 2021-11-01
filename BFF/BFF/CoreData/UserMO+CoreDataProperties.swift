//
//  UserMO+CoreDataProperties.swift
//  BFF
//
//  Created by yulin on 2021/10/30.
//
//

import Foundation
import CoreData


extension UserMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserMO> {
        return NSFetchRequest<UserMO>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var petsIds: [String]?

}

extension UserMO : Identifiable {

}
