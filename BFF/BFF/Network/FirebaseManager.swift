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


// swiftlint:disable file_length
class FirebaseManager {

    static let shared = FirebaseManager()
    lazy var dateBase = Firestore.firestore()
    lazy var storage = Storage.storage()

    let userId = Auth.auth().currentUser?.uid ?? ""
    let userEmail = Auth.auth().currentUser?.email ?? ""
    let userName = Auth.auth().currentUser?.displayName ?? ""

    func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {

        print("Start fetch UserData ........")

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
                let newUserDoc = self.dateBase.collection("Users").document(self.userId)
                let newUserData = User(userId: self.userId, email: self.userEmail, userName: self.userName)

                do {
                    try newUserDoc.setData(from: newUserData)
                } catch {
                }
            }
        }
    }


    func updateCurrentUserFollow(followPetId: String ) {


        let currentUserDB = dateBase.collection("Users").document(userId)

        currentUserDB.updateData(["followedPets": FieldValue.arrayUnion([followPetId])])
    }

    func removeCurrentUserFollow(followPetId: String ) {


        let currentUserDB = dateBase.collection("Users").document(userId)

        currentUserDB.updateData(["followedPets": FieldValue.arrayRemove([followPetId])])
    }

    func updateCurrentUserBlockPets(blockPetId: String ) {


        let currentUserDB = dateBase.collection("Users").document(userId)

        currentUserDB.updateData(["blockPets": FieldValue.arrayUnion([blockPetId])])
    }

    func unBlockPets(blockPetId: String ) {

        let currentUserDB = dateBase.collection("Users").document(userId)

        currentUserDB.updateData(["blockPets": FieldValue.arrayRemove([blockPetId])])
    }

    func updateUserInfo(user: User, newimage: UIImage, completion: @escaping (Result<String, Error>) -> Void) {

        print("Strat UpDateUser\(user.userId)....................")
        if let pic = user.userThumbNail {
            deletePhoto(fileName: pic.fileName, filePath: .userPhotos)
        }
        uploadPhoto(image: newimage, filePath: .userPhotos) { result in
            print("Strat UpDatePetPhoto\(newimage)....................")
            switch result {
            case .success(let pic):
                var newUserData = user
                newUserData.userThumbNail?.url = pic.url
                newUserData.userThumbNail?.fileName = pic.fileName

                let userDB = self.dateBase.collection("Users").document(newUserData.userId)
                do {
                    try userDB.setData(from: newUserData)
                    completion(.success("Succes"))
                } catch {
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func updateUserInfo(user: User, completion: @escaping (Result<String, Error>) -> Void) {

        print("Strat UpDateUser\(user.userId)....................")

                let userDB = self.dateBase.collection("Users").document(user.userId)
                do {
                    try userDB.setData(from: user)
                    completion(.success("Succes"))
                } catch {
                    completion(.failure(error))

        }
    }




    func fetchUserInfo(userId: String, completion: @escaping (Result<User, Error>) -> Void) {

        print("Start fetch UserData ........")

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

            }
        }
    }

    func listenUser(completion: @escaping (Result<User, Error>) -> Void) {

        print("Start listen UserData........")

        dateBase.collection("Users").document(userId).addSnapshotListener { documentSnapshot, error in
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

    func listenNotifications(completion: @escaping (Result<[Notification], Error>) -> Void) {
        dateBase.collection("Users").document(userId).collection("Notifications").addSnapshotListener { querySnapshot, error in
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


    func creatNotification(newNotify: Notification) {

        let document =   dateBase.collection("Users").document(userId).collection("Notifications").document(newNotify.id)
        do {
            try document.setData(from: newNotify)
            print("upLoad NotificationInFo Success - \(newNotify) ")
        } catch {
            print("upLoad NotificationInFo Success - \(error) ")
        }
    }


    func createAndUpdateNotification(newNotify: Notification) {

        let document =   dateBase.collection("Users").document(userId).collection("Notifications").document(newNotify.id)

        do {
            try document.setData(from: newNotify)
            print(document)
        } catch {
            print(error)
        }
    }

    func removeNotification(notifyId:String){

        let document =   dateBase.collection("Users").document(userId).collection("Notifications").document(notifyId)


        document.delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }

    }

    // swiftlint:disable cyclomatic_complexity
    func listMessages(completion: @escaping (Result<[Message], Error>) -> Void) {


        var messages = [Message]()
        dateBase.collection("Messages").whereField("receiver", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapshot = querySnapshot {
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Message.self) {

                                if !messages.contains(where: { message in
                                    return message.messageId == data.messageId
                                }){
                                    messages.append(data)
                                }

                                completion(.success(messages))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
        dateBase.collection("Messages").whereField("sender", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { document in
                    do {
                        if let data = try document.data(as: Message.self) {

                            if !messages.contains(where: { message in
                                return message.messageId == data.messageId
                            }){
                                messages.append(data)
                            }
                            completion(.success(messages))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }

        }
    }


    func listMessages(otherUserId: String,completion: @escaping (Result<[Message], Error>) -> Void) {

        var messages = [Message]()
        dateBase.collection("Messages").whereField("receiver", isEqualTo: otherUserId).whereField("sender", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapshot = querySnapshot {
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Message.self) {

                                if !messages.contains(where: { message in
                                    return message.messageId == data.messageId
                                }){
                                    messages.append(data)
                                }

                                completion(.success(messages))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
        dateBase.collection("Messages").whereField("sender", isEqualTo: otherUserId).whereField("receiver", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                querySnapshot.documents.forEach { document in
                    do {
                        if let data = try document.data(as: Message.self) {

                            if !messages.contains(where: { message in
                                return message.messageId == data.messageId
                            }){
                                messages.append(data)
                            }
                            completion(.success(messages))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }

        }

    }


    func sendMessage(reciverId: String, content: String ){

        let douctment = dateBase.collection("Messages").document()
        let message = Message(content: content, createdTime: Timestamp.init(date: Date()), receiver: reciverId, sender: userId, messageId: douctment.documentID)
        do {
            try douctment.setData(from: message)

        } catch {
            print(error)
        }


    }



    func addPetToUser(petId: String) {
        dateBase.collection("Users").document(userId).updateData(["petsIds": FieldValue.arrayUnion([petId])])
    }


    func removePet(petId:String){

        let document =   dateBase.collection("Pets").document(petId)

        document.delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }

    }

    func removePetFromUser(petId: String) {
        dateBase.collection("Users").document(userId).updateData(["petsIds": FieldValue.arrayRemove([petId])])
        dateBase.collection("Users").document(userId).collection("Notification").whereField("fromPets", arrayContains: petId).getDocuments { querySnapshot, error in

            if let error = error {

            } else {
                if let querySnapshot = querySnapshot {
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Notification.self) {
                                if data.fromPets.count == 1 {
                                    self.dateBase.collection("Users").document(self.userId).collection("Notification").document(document.documentID).delete()
                                } else {
                                    // swiftlint:disable:next line_length
                                    self.dateBase.collection("Users").document(self.userId).collection("Notification").document(document.documentID).updateData(["fromPets": FieldValue.arrayRemove([petId])])
                                }
                            }
                        } catch {

                        }
                    }

                }
            }
        }

        dateBase.collection("Users").document(userId).collection("Supplies").whereField("forPets", arrayContains: petId).getDocuments { querySnapshot, error in

            if let error = error {

            } else {
                if let querySnapshot = querySnapshot {
                    querySnapshot.documents.forEach { document in
                        do {
                            self.dateBase.collection("Users").document(self.userId).collection("Supplies").document(document.documentID).updateData(["petsIds": FieldValue.arrayRemove([petId])])
                        } catch {

                        }
                    }

                }
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

        guard !petIds.isEmpty else { return }

        dateBase.collection("Pets").whereField("petId", in: petIds).getDocuments { (querySnapshot, error) in

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



    func fetchUserPets(completion: @escaping (Result<[Pet], Error>) -> Void) {

        print("Start fetch UserPetsData ........")
        
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


    func listenUsersPets(completion: @escaping (Result<[Pet], Error>) -> Void) {

        print(" start listen UsersPets........")

        dateBase.collection("Pets").whereField("userId", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapshot = querySnapshot {
                    var pets = [Pet]()
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Pet.self) {
                                print(data)
                                pets.append(data)
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                    completion(.success(pets))
                }
            }
        }
    }


    func listenPets(completion: @escaping (Result<[Pet], Error>) -> Void) {

        print(" start listen UsersPets........")

        dateBase.collection("Pets").addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let querySnapshot = querySnapshot {
                    var pets = [Pet]()
                    querySnapshot.documents.forEach { document in
                        do {
                            if let data = try document.data(as: Pet.self) {
                                print(data)
                                pets.append(data)
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                    completion(.success(pets))
                }
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


    func updatePet(upDatepetId: String, newimage:UIImage, data:Pet, completion: @escaping (Result<String, Error>) -> Void) {


        print("Strat UpDatePet\(upDatepetId)....................")
        if let pic = data.petThumbnail {
            deletePhoto(fileName: pic.fileName, filePath: .petPhotos)
        }
        uploadPhoto(image: newimage, filePath: .petPhotos) { result in
            print("Strat UpDatePetPhoto\(newimage)....................")
            switch result {
            case .success(let pic):
                print("UpDatePetPhotoSucess\(pic)....................")
                print("UpDatePetToDB....................")
                self.dateBase.collection("Pets").document(upDatepetId).updateData([
                    "petId": data.petId,
                    "name": data.name,
                    "userId": self.userId,
                    "healthInfo.birthday": data.healthInfo.birthday,
                    "healthInfo.chipId": data.healthInfo.chipId,
                    "healthInfo.gender": data.healthInfo.gender,
                    "healthInfo.note": data.healthInfo.note,
                    "healthInfo.type": data.healthInfo.type,
                    "healthInfo.weight": data.healthInfo.weight,
                    "healthInfo.weightUnit": data.healthInfo.weightUnit,
                    "petThumbnail.url": pic.url ,
                    "petThumbnail.fileName": pic.fileName
                ])
                completion(.success("Succes"))
            case .failure(let error):
                completion(.failure(error))
                print("fetchData.failure\(error)")

            }
        }
    }


    func listenDiaries(completion: @escaping (Result<[Diary], Error>) -> Void) {

        dateBase.collection("Diaries").addSnapshotListener { (querySnapshot, error) in

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

                let sortDiary = diaries.sorted { firstDiary, secondDiary in
                    return firstDiary.createdTime.dateValue() > secondDiary.createdTime.dateValue()
                }
                completion(.success(sortDiary))
            }
        }
    }






    func fetchAllDiaries(completion: @escaping (Result<[Diary], Error>) -> Void) {

        dateBase.collection("Diaries").whereField("isPublic", isEqualTo: true).getDocuments { (querySnapshot, error) in

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

                let sortDiary = diaries.sorted { firstDiary, secondDiary in
                    return firstDiary.createdTime.dateValue() > secondDiary.createdTime.dateValue()
                }
                completion(.success(sortDiary))
            }
        }
    }


    func fetchPetAllDiaries(petId: String, completion: @escaping (Result<[Diary], Error>) -> Void) {

        dateBase.collection("Diaries").whereField("petId", isEqualTo: petId).getDocuments { (querySnapshot, error) in

            if let error = error {
                completion(.failure(error))
            } else {
                var diaries = [Diary]()
                for document in querySnapshot!.documents {

                    do {
                        if let diary = try document.data(as: Diary.self, decoder: Firestore.Decoder()) {
                            diaries.append(diary)
                        }

                    } catch {

                        completion(.failure(error))
                    }
                }

                let sortDiary = diaries.sorted { firstDiary, secondDiary in
                    return firstDiary.createdTime.dateValue() > secondDiary.createdTime.dateValue()
                }
                completion(.success(sortDiary))
            }
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

                let sortDiary = diaries.sorted { firstDiary, secondDiary in
                    return firstDiary.createdTime.dateValue() > secondDiary.createdTime.dateValue()
                }
                completion(.success(sortDiary))
            }
        }
    }

    func creatDiary(content: String, pics: [Pic], isPublic: Bool, petTags: [String], petId:String) {

        let diariesRef = dateBase.collection("Diaries")
        let document = diariesRef.document()

        let diary = Diary(content: content, diaryId: document.documentID, images: pics, isPublic: isPublic, petTags: petTags, userId: userId, petId: petId)

        do {
            try document.setData(from: diary)
            print(document)
        } catch {
            print(error)
        }
    }

    enum FilePathName: String {
        case dairyPhotos = "DairyPhotos"
        case petPhotos = "PetPhotoss"
        case userPhotos = "UserPhotos"
    }

    func uploadPhoto(image: UIImage, filePath: FilePathName, completion: @escaping (Result<Pic, Error>) -> Void) {

        let fileName = "\(NSUUID().uuidString).jpg"
        print(fileName)
        let storageRef = storage.reference().child(filePath.rawValue).child(fileName)

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
                        let pic = Pic(url: urlString, fileName: fileName)
                        print(fileName)
                        completion(.success(pic))
                    }
                }

            }
        }
    }


    func getPhoto(fileName: String, filePath: FilePathName, completion: @escaping (Result<Pic, Error>) -> Void)  {

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


    func deletePhoto(fileName: String, filePath: FilePathName){
        print("Strat DeletePhoto\(fileName)....................")
        let storageRef = storage.reference().child(filePath.rawValue).child(fileName)
        storageRef.delete { error in
            if let error = error {
                print("DeletePhotoFlsae....................")
                print(error)
            } else {
                print("DeletePhotoScess....................")
            }
        }

    }




    func updateDiaryPrivacy(diaryId: String, isPublic: Bool) {
        dateBase.collection("Diaries").document(diaryId).updateData(["isPublic": isPublic])
    }

    func updateDiaryContent(diaryId: String, content: String) {
        ProgressHUD.show()
        dateBase.collection("Diaries").document(diaryId).updateData(["content": content])
        ProgressHUD.showSuccess(text: "更新成功")
    }

    func upDateDiaryLiked(diaryId: String, isLiked: Bool) {

        ProgressHUD.show()

        if isLiked {

            dateBase.collection("Diaries").document(diaryId).updateData(["whoLiked": FieldValue.arrayUnion([userId])])
            ProgressHUD.showSuccess(text: "Liked")

        } else{
            dateBase.collection("Diaries").document(diaryId).updateData(["whoLiked": FieldValue.arrayRemove([userId])])
            ProgressHUD.showSuccess(text: "UnLiked")
        }

    }


    func delateDiary(diaryId: String, diatyPics: [Pic], completion: @escaping (Result<String, Error>) -> Void) {
        diatyPics.forEach { pic in
            deletePhoto(fileName: pic.fileName, filePath: .dairyPhotos)
        }

        dateBase.collection("Diaries").document(diaryId).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let sucessMessage = "Deleate sucess"
                completion(.success(sucessMessage))
            }
        }
    }


    func fetchComments(diaryId:String, completion: @escaping (Result<[Comment], Error>) -> Void) {

        dateBase.collection("Comments").whereField("diaryId", isEqualTo: diaryId).getDocuments { (querySnapshot, error) in

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

    func creatComments(content: String, petId: String, diaryId: String) {

        let commentsRef = dateBase.collection("Comments")
        let document = commentsRef.document()
        let comment = Comment(commentId: document.documentID, content: content, createdTime: Timestamp(date: Date()), diaryId: diaryId, petId: petId)

        do {
            try document.setData(from: comment)
            dateBase.collection("Diaries").document(diaryId).updateData(["comments": FieldValue.arrayUnion([document.documentID])])
            print(document)
        } catch {
            print(error)
        }


    }


    // Can Refactor with Ftech Notificaation?
    func fetchSupplies(completion: @escaping (Result<[Supply], Error>) -> Void) {

        dateBase.collection("Users").document(userId).collection("Supplies").getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var supplies = [Supply]()

                for document in querySnapshot!.documents {

                    do {
                        if var supply = try document.data(as: Supply.self, decoder: Firestore.Decoder()) {


                            let daysBetweenDate = supply.lastUpdate.dateValue().daysBetweenDate(toDate: Date())
                            if daysBetweenDate > 0 {
                                let comsume = supply.perCycleTime * daysBetweenDate
                                var newStock = supply.stock - comsume
                                supply.stock = newStock
                                FirebaseManager.shared.updateSupply(supplyId: supply.supplyId, data: supply)
                                if supply.isReminder == true {
                                    NotificationManger.shared.creatSupplyNotification(supply: supply)
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


    func creatSupply(supply: Supply) {

        let suppliesRef = dateBase.collection("Users").document(userId).collection("Supplies")
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


    func updateSupply(supplyId: String, data:Supply) {

        let supplyRef = dateBase.collection("Users").document(userId).collection("Supplies").document(supplyId)

        supplyRef.updateData([
            "color": data.color,
            "cycleTime": data.cycleTime,
            "forPets": data.forPets,
            "fullStock": data.fullStock,
            "iconImage": data.iconImage,
            "isReminder": data.isReminder,
            "perCycleTime": data.perCycleTime,
            "reminderPercent": data.reminderPercent,
            "stock": data.stock,
            "supplyId": data.supplyId,
            "supplyName": data.supplyName,
            "unit": data.unit,
            "lastUpdate": Timestamp.init(date: Date()) ,
        ])

    }

    func delateSupply(supplyId: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("StartDeleateSupply\(supplyId)")
        dateBase.collection("Users").document(userId).collection("Supplies").document(supplyId).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let sucessMessage = "Deleate sucess"
                completion(.success(sucessMessage))
            }
        }
    }


}


