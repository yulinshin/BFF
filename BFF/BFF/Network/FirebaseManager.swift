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

class FirebaseManager {

    static let shared = FirebaseManager()
    lazy var dataBase = Firestore.firestore()
    lazy var storage = Storage.storage()

    static var userId: String {
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
        dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId).collection(Collection.notifications.rawValue).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapshot = querySnapshot {
                    var notifications = [Notification]()
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Notification.self) {
                                
                                print(data)
                                notifications.append(data)
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                    completion(.success(notifications))
                }
            }
        }
    }

    func createNotification(usrId: String = userId, newNotify: Notification) {
        let document =   dataBase.collection(Collection.users.rawValue).document(usrId).collection(Collection.notifications.rawValue).document(newNotify.id)
        do {
            try document.setData(from: newNotify)
            print("upLoad NotificationInFo Success - \(newNotify) ")
        } catch {
            print("upLoad NotificationInFo Success - \(error) ")
        }
    }

    func removeNotification(usrId: String = userId, notifyId: String) {

        let document =   dataBase.collection(Collection.users.rawValue).document(usrId).collection(Collection.notifications.rawValue).document(notifyId)

        document.delete { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }

    }

    // MARK: - Message

    func listenMessageGroup(completion: @escaping (Result<[MessageGroup], FireBaseError>) -> Void) {

        dataBase.collection(Collection.messageGroups.rawValue).whereField("users", arrayContains: FirebaseManager.userId)
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    completion(.failure(FireBaseError.gotFirebaseError(error!)))
                    return
                }

                var groups = [MessageGroup]()

                documents.forEach { document in

                    //                    self.dateBase.collection("MessageGroups").document(document.documentID).delete()
                    if document.exists {

                        do {
                            if let messageGroup = try document.data(as: MessageGroup.self, decoder: Firestore.Decoder()) {
                                groups.append(messageGroup)
                            }
                        } catch {
                            print("Decode Error: \(error)")
                        }
                    }
                }
                completion(.success(groups))
            }
    }

    func listenMessageFromGroup(groupId: String, completion: @escaping (Result<[Message], FireBaseError>) -> Void) {

        dataBase.collection(Collection.messageGroups.rawValue).document(groupId).collection(Collection.messages.rawValue)
            .addSnapshotListener { querySnapshot, error in

                guard let documents = querySnapshot?.documents else {
                    completion(.failure(FireBaseError.gotFirebaseError(error!)))
                    return
                }
                var messages = [Message]()

                documents.forEach { document in
                    do {
                        if let message = try document.data(as: Message.self, decoder: Firestore.Decoder()) {
                            messages.append(message)
                        }
                    } catch {
                        print("Decode Error: \(error)")
                    }
                }
                completion(.success(messages))
            }
    }

    func listenMessageFromUserID(otherUseId: String, completion: @escaping(Result<(messages: [Message], groupId: String), FireBaseError>) -> Void) {

        let currentUserId = FirebaseManager.userId

        dataBase.collection(Collection.messageGroups.rawValue).whereField("users", in: [[currentUserId, otherUseId], [otherUseId, currentUserId]]).getDocuments { querySnapshot, error in

            if let error = error {

                completion(.failure(FireBaseError.gotFirebaseError(error)))

            } else {
                if let querySnapshot = querySnapshot {

                    guard let groupId = querySnapshot.documents.first?.documentID else {

                        self.createMessageGroup(receiverId: otherUseId, content: nil) { result in

                            switch result {

                            case.success(let groupId):
                                self.listenMessageFromGroup(groupId: groupId) { result in

                                    switch result {

                                    case.success(let messages):
                                        completion(.success((messages: messages, groupId: groupId)))

                                    case.failure(let error):
                                        completion(.failure(FireBaseError.gotFirebaseError(error)))

                                    }

                                }

                            case .failure(let error):
                                completion(.failure(FireBaseError.gotFirebaseError(error)))

                            }
                        }

                        return
                    }

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
    }

    func createMessageGroup(receiverId: String, content: String?, completion: @escaping (Result<String, FireBaseError>) -> Void) {

        let document = dataBase.collection(Collection.messageGroups.rawValue).document()
        let newGroup = MessageGroup(groupId: document.documentID, users: [FirebaseManager.userId, receiverId])
        do {
            try document.setData(from: newGroup)

            if let content = content {
                addMessage(document, content, receiverId)
            }

            completion(.success(document.documentID))
        } catch {
            print(error)
        }
    }

    fileprivate func addMessage(_ document: DocumentReference, _ content: String, _ receiverId: String) {
        let messageDoc = document.collection(Collection.messages.rawValue).document()
        let message = Message(content: content, createdTime: Timestamp.init(date: Date()), receiver: receiverId, sender: FirebaseManager.userId, messageId: messageDoc.documentID)
        do {
            try messageDoc.setData(from: message)
        } catch {
            print(error)
        }
    }

    func sendMessage(receiverId: String, groupId: String, content: String ) {

        if groupId == "" {
            createMessageGroup(receiverId: receiverId, content: content) { result in
                switch result {
                case .success(let groupId):
                    print("Create group with message success ID: \(groupId)")
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            let document = dataBase.collection(Collection.messageGroups.rawValue).document(groupId).collection(Collection.messages.rawValue).document()

            let message = Message(content: content, createdTime: Timestamp.init(date: Date()), receiver: receiverId, sender: FirebaseManager.userId, messageId: document.documentID)

            do {
                try document.setData(from: message)

            } catch {
                print(error)
            }

        }
    }

    // MARK: - Comment
    func fetchComments(diaryId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {

        dataBase.collection(Collection.comments.rawValue).whereField("diaryId", isEqualTo: diaryId).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var comments = [Comment]()

                for document in querySnapshot!.documents {

                    do {
                        if let comment = try document.data(as: Comment.self, decoder: Firestore.Decoder()) {
                            comments.append(comment)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                completion(.success(comments))
            }
        }
    }

    func createComments(content: String, petId: String, diaryId: String, diaryOwner: String) {

        let commentsRef = dataBase.collection(Collection.comments.rawValue)
        let document = commentsRef.document()
        let comment = Comment(commentId: document.documentID, content: content, createdTime: Timestamp(date: Date()), diaryId: diaryId, petId: petId)

        do {
            try document.setData(from: comment)
            dataBase.collection(Collection.diaries.rawValue).document(diaryId).updateData(["comments": FieldValue.arrayUnion([document.documentID])])

            if diaryId != FirebaseManager.userId {
                // swiftlint:disable:next line_length
                let notification = Notification(content: "回覆了你的日記貼文", notifyTime: Timestamp(date: Date()), fromPets: [petId], title: "", type: "comment", id: "Comment\(document.documentID)", diaryId: diaryId)
                createNotification(usrId: diaryOwner, newNotify: notification)
            }

            print(document)

        } catch {
            print(error)
        }

    }

    // MARK: - Supply
    func fetchSupplies(completion: @escaping (Result<[Supply], Error>) -> Void) {

        dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId).collection(Collection.supplies.rawValue).getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var supplies = [Supply]()

                for document in querySnapshot!.documents {

                    do {
                        if var supply = try document.data(as: Supply.self, decoder: Firestore.Decoder()) {

                            let daysBetweenDate = supply.lastUpdate.dateValue().daysBetweenDate(toDate: Date())
                            if daysBetweenDate > 0 {
                                let consume = supply.perCycleTime * daysBetweenDate
                                let newStock = supply.stock - consume
                                supply.stock = newStock
                                FirebaseManager.shared.updateSupply(supplyId: supply.supplyId, data: supply)
                                if supply.isReminder == true {
                                    NotificationManger.shared.createSupplyNotification(supply: supply)
                                }
                            }
                            supplies.append(supply)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(supplies))
            }
        }
    }

    func createSupply(supply: Supply) {

        let suppliesRef = dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId).collection(Collection.supplies.rawValue)
        let document = suppliesRef.document()

        var newSupply = supply
        newSupply.supplyId = document.documentID

        do {
            try document.setData(from: newSupply)
            print(document)
        } catch {
            print(error)
        }
    }

    func updateSupply(supplyId: String, data: Supply) {

        let supplyRef = dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId).collection(Collection.notifications.rawValue).document(supplyId)

        var supply = data
        supply.lastUpdate = Timestamp.init(date: Date())

        do {
            try supplyRef.setData(from: supply)
        } catch {
            print(error)
        }
    }

    func delateSupply(supplyId: String, completion: @escaping (Result<String, Error>) -> Void) {
        dataBase.collection(Collection.users.rawValue).document(FirebaseManager.userId).collection(Collection.supplies.rawValue).document(supplyId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let successMessage = "Delete success"
                completion(.success(successMessage))
            }
        }
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
