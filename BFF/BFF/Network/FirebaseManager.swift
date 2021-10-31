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
                fatalError()
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
            print("upLoad NotificartionInFo Sucess - \(newNotify) ")
        } catch {
            print("upLoad NotificartionInFo Sucess - \(error) ")
        }
    }


    func creatAndUpdateNotification(newNotify: Notification) {

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
                        "healthInfo.gender": data.healthInfo.chipId,
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


    // Can Refactor with Ftech Notificaation?
    func fetchSupplies(completion: @escaping (Result<[Supply], Error>) -> Void) {

        dateBase.collection("Users").document(userId).collection("Supplies").getDocuments { (querySnapshot, error) in

            if let error = error {

                completion(.failure(error))
            } else {

                var supplies = [Supply]()

                for document in querySnapshot!.documents {

                    do {
                        if let supply = try document.data(as: Supply.self, decoder: Firestore.Decoder()) {
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
