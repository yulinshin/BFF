//
//  CreatPetViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import Foundation
import UIKit

class CreatPetViewModel {

    let name = Box("")
    let petThumbnail = Box("")
    let allergy = Box("")
    let birthday = Box("")
    let chipId = Box("")
    let gender = Box("")
    let note = Box("")
    let type = Box("")
    let weight = Box(0.0)
    let weightUnit = Box("")

    func updateData(name: String) {
        self.name.value = name
    }

    func updateData(petThumbnail: String) {
        self.petThumbnail.value = petThumbnail
    }

    func updateData(allergy: String) {
        self.allergy.value = allergy
    }

    func updateData(birthday: String) {
        self.birthday.value = birthday
    }

    func updateData(chipId: String) {
        self.chipId.value = chipId
    }

    func updateData(gender: String) {
        self.gender.value = gender
    }

    func updateData(note: String) {
        self.note.value = note
    }

    func updateData(type: String) {
        self.type.value = type
    }

    func updateData(weightUnit: String) {
        self.weightUnit.value = weightUnit
    }

    func updateData(weight: String) {
        guard let weightToDouble = Double(weight) else { return }
        self.weight.value = weightToDouble
    }

    func creatPet(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {

        // swiftlint:disable:next line_length
        var pet = Pet(petId: "", name: self.name.value, userId: "", healthInfo: HealthInfo(birthday: self.birthday.value, chipId: self.chipId.value, gender: self.gender.value, note: self.note.value, type: self.type.value, weight: self.weight.value, weightUnit: self.weightUnit.value), petThumbnail: Pic(url: "", fileName: ""))

        FirebaseManager.shared.uploadPhoto(image: image, filePath: .petPhotos) { result in

            switch result {

            case .success(let urlString):

                pet.petThumbnail = urlString

                completion(.success("ImageUrl = \(urlString)"))

                FirebaseManager.shared.creatPets(newPet: pet)

            case .failure(let error):

                completion(.failure(error))

            }
        }
    }


    func upDatePetToDB(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {

        // swiftlint:disable:next line_length
            let pet = Pet(petId: "", name: self.name.value, userId: "", healthInfo: HealthInfo(birthday: self.birthday.value, chipId: self.chipId.value, gender: self.gender.value, note: self.note.value, type: self.type.value, weight: self.weight.value, weightUnit: self.weightUnit.value), petThumbnail: Pic(url: "", fileName: ""))

                FirebaseManager.shared.updatePet(upDatepetId: pet.petId, newimage: image, data: pet)

        }
}
