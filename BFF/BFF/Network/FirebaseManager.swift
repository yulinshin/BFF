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

        dateBase.collection("Users").document("7QBGUfSDqPPjfJXRpQAI").getDocument { (document, error) in

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

        dateBase.collection("Users").document("7QBGUfSDqPPjfJXRpQAI").collection("Notifications").getDocuments { (querySnapshot, error) in

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
                fatalError()
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

    func fetchPets (userId: String, completion: @escaping (Result<[Pet], Error>) -> Void) {

        dateBase.collection("Pets").whereField("userId", isEqualTo: userId).getDocuments{ (querySnapshot, error) in

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


    func fetchDiaries(userId: String, completion: @escaping (Result<[Diary], Error>) -> Void) {

        dateBase.collection("Diaries").whereField("userId", in: [userId]).getDocuments { (querySnapshot, error) in

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
        
        // swiftlint:disable:next line_length
        var diary = Diary(comments: [String](), content: content, createdTime: Timestamp.init(date:Date()), diaryId: document.documentID, images: imageUrls, isPublic: isPublic, petTags: petTags, userId: userId)

        do {
            try document.setData(from: diary)
            print(document)
        } catch {
            print(error)
        }
    }

    func uploadDiaryPhoto(image: UIImage, completion: @escaping (Result<String, Error>) -> Void)  {

        let storageRef = storage.reference().child("DairyPhotos").child("\(NSUUID().uuidString).jpg")

        var urlString: String?

        guard let data = image.pngData() else { return }

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = storageRef.putData(data, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            return
          }

        storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              return
            }
            if let downloadUrl = url {
                let directoryURL : NSURL = downloadUrl as NSURL
                guard let urlString = directoryURL.absoluteString else { return }
                completion(.success(urlString))
            }
            else {

            }
          }
        }
    }
}
