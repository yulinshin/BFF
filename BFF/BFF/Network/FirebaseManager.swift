//
//  UserManager.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit

class FirebaseManager {

    static let shared = FirebaseManager()

    lazy var dateBase = Firestore.firestore()
    lazy var storage = Storage.storage()

    var userId = "7QBGUfSDqPPjfJXRpQAI"

    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {

        dateBase.collection("Users").document(userId).getDocument { (document, error) in

            if let document = document, document.exists {
                do {
                    if let user = try document.data(as: User.self, decoder: Firestore.Decoder()) {
                        completion(.success(user))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                fatalError()
            }
        }
    }

    func fetchNotifications(completion: @escaping (Result<[Notification], Error>) -> Void) {

        dateBase.collection("Users").document(userId).collection("Notifications").getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var notifications = [Notification]()

                for document in querySnapshot!.documents {

                    do {
                        if let notification = try document.data(as: Notification.self, decoder: Firestore.Decoder()) {
                            notifications.append(notification)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(notifications))
            }
        }
    }

    func fetchPet(petId: String, completion: @escaping (Result<Pet, Error>) -> Void) {

        dateBase.collection("Pets").document(petId).getDocument { (document, error) in

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

        dateBase.collection("Pets").whereField(Firebase.FieldPath.documentID(), in: petIds).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var pets = [Pet]()
                for doucment in querySnapshot!.documents {

                    do {
                        if let pet = try doucment.data(as: Pet.self, decoder: Firestore.Decoder()) {
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

    func fetchPets (completion: @escaping (Result<[Pet], Error>) -> Void) {

        dateBase.collection("Pets").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var pets = [Pet]()
                for doucment in querySnapshot!.documents {
                    do {
                        if let pet = try doucment.data(as: Pet.self, decoder: Firestore.Decoder()) {
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

        let diariesRef = dateBase.collection("Pets")
        let document = diariesRef.document()

        var pet = newPet
        pet.petId = document.documentID
        pet.userId = userId
        do {
            try document.setData(from: pet)
            self.addPetToUser(petId: pet.petId)
            print(document)
        } catch {
            print(error)
        }
    }




    func fetchDiaries(completion: @escaping (Result<[Diary], Error>) -> Void) {

        dateBase.collection("Diaries").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var diaries = [Diary]()
                for doucment in querySnapshot!.documents {

                    do {
                        if let diary = try doucment.data(as: Diary.self, decoder: Firestore.Decoder()) {
                            diaries.append(diary)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }
                completion(.success(diaries))
            }
        }
    }

    func creatDiary(content: String, imageUrls: [String], isPublic: Bool, petTags: [String]) {

        let diariesRef = dateBase.collection("Diaries")
        let document = diariesRef.document()

        let diary = Diary(content: content, diaryId: document.documentID, images: imageUrls, isPublic: isPublic, petTags: petTags, userId: userId, petId: petTags[0])

        do {
            try document.setData(from: diary)
            print(document)
        } catch {
            print(error)
        }
    }



    enum FilePathName : String {
        case dairyPhotos = "DairyPhotos"
        case petPhotos = "PetPhotoss"
    }

    func uploadPhoto(image: UIImage, filePath: FilePathName, completion: @escaping (Result<String, Error>) -> Void) {

        let storageRef = storage.reference().child(filePath.rawValue).child("\(NSUUID().uuidString).jpg")

        guard let data = image.pngData() else { return }

        storageRef.putData(data, metadata: nil) { (_, error) in

            if let error = error {
                completion(.failure(error))
            } else {

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        guard let downloadURL = url else {
                            return
                        }
                        let urlString = downloadURL.absoluteString
                        completion(.success(urlString))
                    }
                }

            }
        }
    }

    func updateDiaryPrivacy(diaryId: String, isPublic: Bool) {
        dateBase.collection("Diaries").document(diaryId).updateData(["isPublic": isPublic])
    }

    func updateDiaryContent(diaryId: String, content: String) {
        dateBase.collection("Diaries").document(diaryId).updateData(["content": content])
    }

    func delateDiary(diaryId: String, completion: @escaping (Result<String, Error>) -> Void){
        dateBase.collection("Diaries").document(diaryId).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let sucessMessage = "Deleate sucess"
                completion(.success(sucessMessage))
            }
        }
    }
}
