//
//  PetHealthCellViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/31.
//

import Foundation
import UIKit
import CoreData

class PetHealthCellViewModel {

    var name = Box(" ")
    var petImage = Box(" ")
    var birthady = Box(" ")
    var petId = Box(" ")
    var photoFile = Box(" ")

    init(from pet: Pet) {
        name.value = pet.name
        petImage.value = pet.petThumbnail?.url ?? " "
        birthady.value = pet.healthInfo.birthday
    }


}
