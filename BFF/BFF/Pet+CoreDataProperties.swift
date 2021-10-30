//
//  Pet+CoreDataProperties.swift
//  
//
//  Created by yulin on 2021/10/30.
//
//

import Foundation
import CoreData


extension Pet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pet> {
        return NSFetchRequest<Pet>(entityName: "Pet")
    }

    @NSManaged public var petId: NSObject?
    @NSManaged public var name: NSObject?
    @NSManaged public var attribute: NSObject?
    @NSManaged public var attribute1: NSObject?
    @NSManaged public var attribute2: NSObject?
    @NSManaged public var attribute3: NSObject?
    @NSManaged public var petThumbmail: Pic?

}
