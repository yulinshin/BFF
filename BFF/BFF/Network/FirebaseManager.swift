//
//  UserManager.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseStorage
import UIKit
import Network
import SwiftUI

enum FireBaseError: Error {

    case noNetWorkContent
    case gotFirebaseError(Error)

}

enum Collection: String {

    case users = "Users"
    case pets = "Pets"
    case diaries = "Diaries"
    case notifications = "Notifications"
    case messages = "Messages"
    case messageGroups = "MessageGroups"
    case supplies = "Supplies"
    case comments = "Comments"

}

enum FilePathName: String {

    case dairyPhotos = "DairyPhotos"
    case petPhotos = "PetPhotoss"
    case userPhotos = "UserPhotos"

}

final class FirebaseManager {

    static let shared = FirebaseManager()
    lazy var dataBase = Firestore.firestore()
    lazy var storage = Storage.storage()
    var publicDiaryPagingLastDoc: QueryDocumentSnapshot?
    var petDiaryPagingLastDoc: QueryDocumentSnapshot?
    var userDiaryPagingLastDoc: QueryDocumentSnapshot?

    var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    var userEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }
    var userName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }
    var currentUser: User?

    // MARK: - Notification

    func listenNotifications(completion: @escaping (Result<[Notification], Error>) -> Void) {

        dataBase.collection(Collection.users.rawValue).document(self.userId).collection(Collection.notifications.rawValue).addSnapshotListener { querySnapshot, error in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(error!))
                return
            }
            let notifications = querySnapshot.documents.compactMap({
                try? $0.data(as: Notification.self)
            })
            completion(.success(notifications))

        }

    }

    func createNotification(userId: String? = nil, newNotify: Notification) {
        let userId = userId ?? self.userId
        let document =   dataBase.collection(Collection.users.rawValue).document(userId).collection(Collection.notifications.rawValue).document(newNotify.id)
        do {
            try document.setData(from: newNotify)
        } catch {
            print("Error creating Notification: \(error)")
        }
    }

    func removeNotification(userId: String? = nil, notifyId: String) {
        let userId = userId ?? self.userId
        let document =   dataBase.collection(Collection.users.rawValue).document(userId).collection(Collection.notifications.rawValue).document(notifyId)
        document.delete { error in
            guard let error = error else { return }
            print("Error removing document: \(error)")
        }

    }

    // MARK: - Message

    func listenMessageGroup(completion: @escaping (Result<[MessageGroup], FireBaseError>) -> Void) {

        dataBase.collection(Collection.messageGroups.rawValue).whereField("users", arrayContains: self.userId)
            .addSnapshotListener { querySnapshot, error in

                guard let querySnapshot = querySnapshot else {
                    print("Error fetching document: \(error!)")
                    completion(.failure(FireBaseError.gotFirebaseError(error!)))
                    return
                }
                let groups = querySnapshot.documents.compactMap({
                    try? $0.data(as: MessageGroup.self)
                })
                completion(.success(groups))

            }

    }

    func listenMessageFromGroup(groupId: String, completion: @escaping (Result<[Message], FireBaseError>) -> Void) {

        dataBase.collection(Collection.messageGroups.rawValue).document(groupId).collection(Collection.messages.rawValue)
            .addSnapshotListener { querySnapshot, error in

                guard let querySnapshot = querySnapshot else {
                    print("Error fetching document: \(error!)")
                    completion(.failure(FireBaseError.gotFirebaseError(error!)))
                    return
                }
                let messages = querySnapshot.documents.compactMap({
                    try? $0.data(as: Message.self)
                })
                completion(.success(messages))

            }

    }

    func listenMessageFromUserID(otherUseId: String, completion: @escaping(Result<(messages: [Message], groupId: String), FireBaseError>) -> Void) {

        dataBase.collection(Collection.messageGroups.rawValue).whereField("users", in: [[userId, otherUseId], [otherUseId, userId]]).getDocuments { querySnapshot, error in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }
            let dispatchQueue = DispatchQueue.global(qos: .background)
            let semaphore = DispatchSemaphore(value: 0)
            dispatchQueue.async {

                var groupId: String?

                if querySnapshot.documents.isEmpty {

                    self.createMessageGroup(receiverId: otherUseId) { result in
                        switch result {
                        case.success(let groupIdData):
                            groupId = groupIdData
                            semaphore.signal()
                        case .failure(let error):
                            completion(.failure(FireBaseError.gotFirebaseError(error)))
                            semaphore.signal()
                        }
                    }

                    semaphore.wait()

                } else {
                    guard let firstDocumentId = querySnapshot.documents.first?.documentID else {
                        print("Error to get first document")
                        return
                    }
                    groupId = firstDocumentId
                }

                guard let groupId = groupId else { return }

                self.listenMessageFromGroup(groupId: groupId) { result in
                    switch result {
                    case.success(let messages):
                        completion(.success((messages: messages, groupId: groupId)))
                    case.failure(let error):
                        completion(.failure(FireBaseError.gotFirebaseError(error)))
                    }
                }
            }
        }
    }

    func createMessageGroup(receiverId: String, completion: @escaping (Result<String, FireBaseError>) -> Void) {

        let document = dataBase.collection(Collection.messageGroups.rawValue).document()
        let newGroup = MessageGroup(groupId: document.documentID, users: [userId, receiverId])
        do {
            try document.setData(from: newGroup)
            completion(.success(document.documentID))

        } catch {
            print("Error to createMessageGroup: \(error)")
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }
    }

    func sendMessage(receiverId: String, groupId: String, content: String, completion: @escaping (Result<Void, FireBaseError>) -> Void) {

        let document = dataBase.collection(Collection.messageGroups.rawValue).document(groupId).collection(Collection.messages.rawValue).document()

        let message = Message(content: content, createdTime: Timestamp.init(date: Date()), receiver: receiverId, sender: userId, messageId: document.documentID)

        do {
            try document.setData(from: message)
            completion(.success(()))

        } catch {
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }
    }

    // MARK: - Comment
    func fetchComments(diaryId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {

        dataBase.collection(Collection.comments.rawValue).whereField("diaryId", isEqualTo: diaryId).getDocuments { (querySnapshot, error) in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }
            let comments = querySnapshot.documents.compactMap({
                try? $0.data(as: Comment.self)
            })
            completion(.success(comments))

        }
    }

    func createComment(content: String, petId: String, diaryId: String, diaryOwner: String, completion: @escaping (Result<Void, Error>) -> Void) {

        let commentDocument = dataBase.collection(Collection.comments.rawValue).document()
        let diaryDocument =  dataBase.collection(Collection.diaries.rawValue).document(diaryId)

        let comment = Comment(commentId: commentDocument.documentID, content: content, createdTime: Timestamp(date: Date()), diaryId: diaryId, petId: petId)

        do {
            try commentDocument.setData(from: comment)
            diaryDocument.updateData(["comments": FieldValue.arrayUnion([commentDocument.documentID])])

            if diaryId != userId {
                let notifyContent = "回覆了你的日記貼文"
                let notifyID = "Comment\(commentDocument.documentID)"
                let notification = Notification(content: notifyContent, notifyTime: Timestamp(date: Date()), fromPets: [petId], title: "", type: "comment", id: notifyID, diaryId: diaryId)
                self.createNotification(userId: diaryOwner, newNotify: notification)
            }
            completion(.success(()))

        } catch {
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }

    }

    // MARK: - Supply
    func fetchSupplies(completion: @escaping (Result<[Supply], FireBaseError>) -> Void) {

        dataBase.collection(Collection.users.rawValue).document(userId).collection(Collection.supplies.rawValue).getDocuments { (querySnapshot, error) in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }
            // Calculate supply consume and update
            var supplies = querySnapshot.documents.compactMap({ try? $0.data(as: Supply.self) })
            supplies = supplies.map {
                var supply = $0
                supply.calculateSupplyInventory()
                return supply
            }
            completion(.success(supplies))

        }
    }

    func createSupply(supply: Supply, completion: @escaping (Result<Void, FireBaseError>) -> Void) {

        let suppliesRef = dataBase.collection(Collection.users.rawValue).document(userId).collection(Collection.supplies.rawValue)
        let document = suppliesRef.document()

        var newSupply = supply
        newSupply.supplyId = document.documentID

        do {
            try document.setData(from: newSupply)
            completion(.success(()))
        } catch {
            print("Error create document: \(error)")
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }
        
    }

    func updateSupply(supplyId: String, data: Supply, completion: @escaping (Result<Void, FireBaseError>) -> Void = {_ in }) {

        let supplyRef = dataBase.collection(Collection.users.rawValue).document(userId).collection(Collection.supplies.rawValue).document(supplyId)

        var supply = data
        supply.lastUpdate = Timestamp.init(date: Date())

        do {
            try supplyRef.setData(from: supply)
            completion(.success(()))
        } catch {
            print("Error setData document: \(error)")
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }
    }

    func delateSupply(supplyId: String, completion: @escaping (Result<Void, FireBaseError>) -> Void = {_ in }) {
        dataBase.collection(Collection.users.rawValue).document(userId).collection(Collection.supplies.rawValue).document(supplyId).delete { error in
            if let error = error {
                print("Error setData document: \(error)")
                completion(.failure(FireBaseError.gotFirebaseError(error)))
            } else {
                completion(.success(()))
            }
        }

        self.removeNotification(notifyId: "Supply_\(supplyId)")
    }

    // MARK: - FireStorage

    func uploadPhoto(image: UIImage, filePath: FilePathName, completion: @escaping (Result<Pic, FireBaseError>) -> Void) {

        guard NetStatusManger.share.isConnected else {
            completion(.failure(FireBaseError.noNetWorkContent))
            return
        }

        let fileName = "\(NSUUID().uuidString).jpg"
        print(fileName)
        let storageRef = storage.reference().child(filePath.rawValue).child(fileName)

        guard let data = image.pngData() else { return }

        storageRef.putData(data, metadata: nil) { (_, error) in

            if let error = error {
                completion(.failure(.gotFirebaseError(error)))
            } else {

                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(.gotFirebaseError(error)))
                    } else {
                        guard let downloadURL = url else {
                            return
                        }
                        let urlString = downloadURL.absoluteString
                        let pic = Pic(url: urlString, fileName: fileName)
                        print(fileName)
                        completion(.success(pic))
                    }
                }
            }
        }
    }

    func getPhoto(fileName: String, filePath: FilePathName, completion: @escaping(Result<Pic, Error>) -> Void) {

        let storageRef = storage.reference().child(filePath.rawValue).child(fileName)

        storageRef.downloadURL { (url, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let downloadURL = url else {
                    return
                }
                let urlString = downloadURL.absoluteString
                let pic = Pic(url: urlString, fileName: fileName)
                completion(.success(pic))
            }
        }
    }

    func deletePhoto(fileName: String, filePath: FilePathName) {
        let storageRef = storage.reference().child(filePath.rawValue).child(fileName)
        storageRef.delete { error in
            if let error = error {
                print(error)
            }
        }

    }
}
