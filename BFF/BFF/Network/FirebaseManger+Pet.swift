//
//  FirebaseManger+Pet.swift
//  BFF
//
//  Created by yulin on 2021/11/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit
import Network

extension FirebaseManager {

    func updatePetFollower(petId: String) {

        let targetPetsDBRef = dataBase.collection(Collection.pets.rawValue).document(petId)
        targetPetsDBRef.updateData(["followers": FieldValue.arrayUnion([FirebaseManager.userId])])
    }

    func removePetFollower(petId: String) {

        let targetPetsDBRef = dataBase.collection(Collection.pets.rawValue).document(petId)
        targetPetsDBRef.updateData(["followers": FieldValue.arrayRemove([FirebaseManager.userId])])
    }

    func addPetToUser(petId: String) {
        dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId).updateData(["petsIds": FieldValue.arrayUnion([petId])])
    }

    func removePet(petId: String) {

        let document = dataBase.collection(Collection.pets.rawValue).document(petId)

        document.delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

    func removePetFromUser(petId: String) {

        let userDocumentRef = dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId)
        let userNotificationDocRef = userDocumentRef.collection(Collection.notifications.rawValue)
        let userSuppliesDocRef = userDocumentRef.collection(Collection.supplies.rawValue)
        userDocumentRef.updateData(["petsIds": FieldValue.arrayRemove([petId])])
        userNotificationDocRef.whereField("fromPets", arrayContains: petId).getDocuments { querySnapshot, error in
            if let error = error {
                print(error)
            } else {
                if let querySnapshot = querySnapshot {
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Notification.self) {
                                if data.fromPets.count == 1 {
                                    userNotificationDocRef.document(document.documentID).delete()
                                } else {
                                    userNotificationDocRef.document(document.documentID).updateData(["fromPets": FieldValue.arrayRemove([petId])])
                                }
                            }
                        } catch {

                        }
                    }
                }
            }
        }

        userSuppliesDocRef.whereField("forPets", arrayContains: petId).getDocuments { querySnapshot, error in

            if let error = error {
                print(error)
            } else {
                if let querySnapshot = querySnapshot {
                    querySnapshot.documents.forEach { document in
                        userSuppliesDocRef.document(document.documentID).updateData(["petsIds": FieldValue.arrayRemove([petId])])
                    }
                }
            }
        }
    }

    func fetchPet(petId: String, completion: @escaping(Result<Pet, Error>) -> Void) {

        dataBase.collection(Collection.pets.rawValue).document(petId).getDocument { (document, error) in

            if let document = document, document.exists {
                do {
                    if let pet = try document.data(as: Pet.self, decoder: Firestore.Decoder()) {
                        completion(.success(pet))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                return
            }
        }
    }

    func fetchPets(petIds: [String], completion: @escaping (Result<[Pet], Error>) -> Void) {

        guard !petIds.isEmpty else { return }

        dataBase.collection(Collection.pets.rawValue).whereField("petId", in: petIds).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var pets = [Pet]()
                for document in querySnapshot!.documents {

                    do {
                        if let pet = try document.data(as: Pet.self, decoder: Firestore.Decoder()) {
                            pets.append(pet)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }
                completion(.success(pets))
            }
        }
    }

    func fetchUserPets(completion: @escaping (Result<[Pet], Error>) -> Void) {

        dataBase.collection(Collection.pets.rawValue).whereField("userId", isEqualTo: FirebaseManager.userId).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var pets = [Pet]()
                for document in querySnapshot!.documents {

                    do {
                        if let pet = try document.data(as: Pet.self, decoder: Firestore.Decoder()) {
                            pets.append(pet)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }
                completion(.success(pets))
            }
        }
    }

    func fetchPets(completion: @escaping (Result<[Pet], Error>) -> Void) {

        dataBase.collection(Collection.pets.rawValue).whereField("userId", isEqualTo: FirebaseManager.userId).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var pets = [Pet]()
                for document in querySnapshot!.documents {
                    do {
                        if let pet = try document.data(as: Pet.self, decoder: Firestore.Decoder()) {
                            pets.append(pet)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }
                completion(.success(pets))
            }
        }
    }

    func creatPets(newPet: Pet) {

        let diariesRef = dataBase.collection(Collection.pets.rawValue)
        let document = diariesRef.document()

        var pet = newPet
        pet.petId = document.documentID
        pet.userId = FirebaseManager.userId
        do {
            try document.setData(from: pet)
            self.addPetToUser(petId: pet.petId)
            print(document)
        } catch {
            print(error)
        }
    }

    func updatePet(updatePetId: String, newImage: UIImage, data: Pet, completion: @escaping(Result<String, Error>) -> Void) {

        if let pic = data.petThumbnail {
            deletePhoto(fileName: pic.fileName, filePath: .petPhotos)
        }
        uploadPhoto(image: newImage, filePath: .petPhotos) { result in
            switch result {
            case .success(let pic):
                var pet = data
                pet.petThumbnail = pic
                pet.userId = FirebaseManager.userId
                let petDocumentRef = self.dataBase.collection(Collection.pets.rawValue).document(updatePetId)
                do {
                    try petDocumentRef.setData(from: pet)
                    completion(.success("Succes"))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
