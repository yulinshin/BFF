//
//  CreatPetViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import Foundation
import UIKit
import Kingfisher
import AVFoundation

class CreatePetViewModel {

    let name = Box("")
    let petThumbnail = Box("")
    let birthday = Box("")
    let chipId = Box("")
    let gender = Box("")
    let note = Box("")
    let type = Box("")
    let weight = Box(0.0)
    let weightUnit = Box("")
    let photoFile = Box("")
    let petId = Box("")

    init(from pet: Pet) {
        name.value = pet.name
        petThumbnail.value = pet.petThumbnail?.url ?? ""
        birthday.value = pet.healthInfo.birthday
        chipId.value = pet.healthInfo.chipId
        gender.value = pet.healthInfo.gender
        note.value = pet.healthInfo.note
        type.value = pet.healthInfo.type
        weight.value = pet.healthInfo.weight
        weightUnit.value = pet.healthInfo.weightUnit
        photoFile.value = pet.petThumbnail?.fileName ?? ""
        petId.value = pet.petId
    }

    init() {
    }

    func updateData(name: String) {
        self.name.value = name
    }

    func updateData(petThumbnail: String) {
        self.petThumbnail.value = petThumbnail
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
        let pet = Pet(petId: self.petId.value, name: self.name.value, userId: "", healthInfo: HealthInfo(birthday: self.birthday.value, chipId: self.chipId.value, gender: self.gender.value, note: self.note.value, type: self.type.value, weight: self.weight.value, weightUnit: self.weightUnit.value), petThumbnail: Pic(url: self.petThumbnail.value, fileName: self.photoFile.value))

        FirebaseManager.shared.updatePet(updatePetId: pet.petId, newImage: image, data: pet) { result in
            switch result {

            case.success(let message):

                completion(.success(message))

            case.failure(let error):

                completion(.failure(error))

            }
        }

    }

    func deletePet() {

        FirebaseManager.shared.deletePhoto(fileName: photoFile.value, filePath: .petPhotos)

        FirebaseManager.shared.removePet(petId: petId.value)

        FirebaseManager.shared.removePetFromUser(petId: petId.value)

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {

            let context = appDelegate.persistentContainer.viewContext
            do {
                let requests = try context.fetch(PetMO.fetchRequest())
                for request in requests {
                    if request.petId == petId.value {
                        context.delete(request)
                    }
                    appDelegate.saveContext()
                }
            } catch {
                fatalError("\(error)")
            }

        }

    }
}
