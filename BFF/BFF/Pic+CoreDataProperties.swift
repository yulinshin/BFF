//
//  Pic+CoreDataProperties.swift
//  
//
//  Created by yulin on 2021/10/30.
//
//

import Foundation
import CoreData


extension Pic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pic> {
        return NSFetchRequest<Pic>(entityName: "Pic")
    }

    @NSManaged public var url: String?
    @NSManaged public var fileName: String?

}
