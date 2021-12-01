//
//  FirebaseManger+Diary.swift
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

    func createDiary(diary: Diary, completion: @escaping(Result<String, FireBaseError>) -> Void) {

        guard NetStatusManger.share.isConnected else {
            completion(.failure(FireBaseError.noNetWorkContent))
            return
        }

        let diariesRef = dataBase.collection(Collection.diaries.rawValue)
        let document = diariesRef.document()
        var diary = diary
        diary.diaryId = document.documentID

        do {
            try document.setData(from: diary)
            completion(.success("Success upload Diary-\(diary.diaryId)"))
        } catch {
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }
    }

    func fetchPublicDiaries(completion: @escaping (Result<[Diary], Error>) -> Void) {

        dataBase.collection(Collection.diaries.rawValue).whereField("isPublic", isEqualTo: true).getDocuments { (querySnapshot, error) in

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

    func fetchDiary(diaryId: String, completion: @escaping (Result<Diary, Error>) -> Void) {

        dataBase.collection(Collection.diaries.rawValue).document(diaryId).getDocument { (document, error) in

            if let document = document, document.exists {
                do {
                    if let diary = try document.data(as: Diary.self, decoder: Firestore.Decoder()) {
                        completion(.success(diary))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchPetAllDiaries(petId: String, completion: @escaping (Result<[Diary], Error>) -> Void) {

        dataBase.collection(Collection.diaries.rawValue).whereField("petId", isEqualTo: petId).getDocuments { (querySnapshot, error) in

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

        dataBase.collection(Collection.diaries.rawValue).whereField("userId", isEqualTo: FirebaseManager.userId).getDocuments { (querySnapshot, error) in

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

    func updateDiaryPrivacy(diaryId: String, isPublic: Bool) {
        dataBase.collection(Collection.diaries.rawValue).document(diaryId).updateData(["isPublic": isPublic])
    }

    func updateDiaryContent(diaryId: String, content: String) {
        ProgressHUD.show()
        dataBase.collection(Collection.diaries.rawValue).document(diaryId).updateData(["content": content])
        ProgressHUD.showSuccess(text: "更新成功")
    }

    func upDateDiaryLiked(diaryId: String, isLiked: Bool) {

        ProgressHUD.show()

        if isLiked {

            dataBase.collection(Collection.diaries.rawValue).document(diaryId).updateData(["whoLiked": FieldValue.arrayUnion([FirebaseManager.userId])])
            ProgressHUD.showSuccess(text: "Liked")

        } else {

            dataBase.collection(Collection.diaries.rawValue).document(diaryId).updateData(["whoLiked": FieldValue.arrayRemove([FirebaseManager.userId])])
            ProgressHUD.showSuccess(text: "UnLiked")

        }

    }

    func deleteDiary(diaryId: String, diaryPics: [Pic], completion: @escaping (Result<String, Error>) -> Void) {
        diaryPics.forEach { pic in
            deletePhoto(fileName: pic.fileName, filePath: .dairyPhotos)
        }

        dataBase.collection(Collection.diaries.rawValue).document(diaryId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                let sucessMessage = "Deleate sucess"
                completion(.success(sucessMessage))
            }
        }
    }

}
