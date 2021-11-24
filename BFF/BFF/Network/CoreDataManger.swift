//
//  CoreDataManger.swift
//  BFF
//
//  Created by yulin on 2021/11/6.

import Foundation
import CoreData
import UIKit

class CoreDataManager {

    static let sharedInstance: CoreDataManager = {
        let instance = CoreDataManager()
        return instance
    }()

    func fetchMyPets() -> [PetMO]? {

        var myPets = [PetMO]()
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            let context = appDelegate.persistentContainer.viewContext
            do {
                let requests = try context.fetch(PetMO.fetchRequest())
                myPets = requests
            } catch {
                fatalError("CodataERROR:\(error)")
            }
        }
        return myPets
    }

}
