//
//  PicMO+CoreDataProperties.swift
//  BFF
//
//  Created by yulin on 2021/10/30.
//
//

import Foundation
import CoreData


extension PicMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PicMO> {
        return NSFetchRequest<PicMO>(entityName: "Pic")
    }

    @NSManaged public var url: String?
    @NSManaged public var fileName: String?

}

extension PicMO : Identifiable {

}
