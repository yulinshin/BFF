//
//  PetMO+CoreDataProperties.swift
//  BFF
//
//  Created by yulin on 2021/10/30.
//
//

import Foundation
import CoreData


extension PetMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PetMO> {
        return NSFetchRequest<PetMO>(entityName: "Pet")
    }

    @NSManaged public var name: String?
    @NSManaged public var petId: String?
    @NSManaged public var thumbNail: PicMO?

}

extension PetMO : Identifiable {

}
