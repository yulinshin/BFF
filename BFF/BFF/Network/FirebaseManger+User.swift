//
//  FirebaseManger+User.swift
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

    func fetchUserInfo(userId: String? = nil, completion: @escaping (Result<User, Error>) -> Void) {
        let userId = userId ?? self.userId
        dataBase.collection(Collection.users.rawValue).document(userId).getDocument { document, error in

            if let document = document, document.exists {

                do {
                    if let user = try document.data(as: User.self, decoder: Firestore.Decoder()) {
                        completion(.success(user))
                        self.currentUser = user
                    }
                } catch { 
                    completion(.failure(error))
                }

            } else {
                self.createUser()
            }

        }
    }

    func createUser() {
        let documentRef = dataBase.collection(Collection.users.rawValue).document(FirebaseManager.shared.userId)
        documentRef.getDocument { (document, error) in
            let newUserData = User(userId: FirebaseManager.shared.userId, email: self.userEmail, userName: self.userName)
            if let document = document, document.exists {
                do {
                    try  documentRef.setData(from: newUserData)
                } catch {
                }
            } else {
                let newDocumentRef = self.dataBase.collection(Collection.users.rawValue).document(FirebaseManager.shared.userId)
                do {
                    try newDocumentRef.setData(from: newUserData)
                } catch {
                    print("Create user error \n \(error) ")
                }
            }
        }
    }

    func updateBlockUser(blockUserId: String) {

        let currentUserDBRef = dataBase.collection(Collection.users.rawValue).document(FirebaseManager.shared.userId)
        currentUserDBRef.updateData(["blockUsers": FieldValue.arrayUnion([blockUserId])])

    }

    func unblockUser(blockUserId: String ) {

        let currentUserDB = dataBase.collection(Collection.users.rawValue).document(FirebaseManager.shared.userId)
        currentUserDB.updateData(["blockUsers": FieldValue.arrayRemove([blockUserId])])

    }

    func updateUserInfo(user: User, newImage: UIImage?, completion: @escaping (Result<String, Error>) -> Void) {
        if let newImage = newImage {
            if let pic = user.userThumbNail {
                deletePhoto(fileName: pic.fileName, filePath: .userPhotos)
            }
            uploadPhoto(image: newImage, filePath: .userPhotos) { result in
                switch result {
                case .success(let pic):
                    var newUserData = user
                    newUserData.userThumbNail = pic
                    let userDB = self.dataBase.collection(Collection.users.rawValue).document(newUserData.userId)
                    do {
                        try userDB.setData(from: newUserData)
                        completion(.success("Succes"))
                    } catch {
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            let userDB = self.dataBase.collection(Collection.users.rawValue).document(user.userId)
            do {
                try userDB.setData(from: user)
                completion(.success("Succes"))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func listenUser(completion: @escaping (Result<User, Error>) -> Void) {

        dataBase.collection(Collection.users.rawValue).document(FirebaseManager.shared.userId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let documentSnapshot = documentSnapshot {

                    do {
                        if let user = try documentSnapshot.data(as: User.self, decoder: Firestore.Decoder()) {
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
    }

}
