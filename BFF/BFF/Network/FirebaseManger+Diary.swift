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
            completion(.success(diary.diaryId))
        } catch {
            completion(.failure(FireBaseError.gotFirebaseError(error)))
        }
    }

    func fetchPublicDiaries(completion: @escaping (Result<[Diary], FireBaseError>) -> Void) {

        var documentsRef = dataBase.collection(Collection.diaries.rawValue)
            .whereField("isPublic", isEqualTo: true)
            .order(by: "createdTime", descending: true)
            .limit(to: 10)

        if let publicDiaryPagingLastDoc = publicDiaryPagingLastDoc {
            documentsRef = documentsRef.start(afterDocument: publicDiaryPagingLastDoc)
        }

        documentsRef.getDocuments { (querySnapshot, error) in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }

            self.publicDiaryPagingLastDoc = querySnapshot.documents.last
            let diaries = querySnapshot.documents.compactMap({
                try? $0.data(as: Diary.self)
            })
            completion(.success(diaries))

        }
    }

    func fetchDiary(diaryId: String, completion: @escaping (Result<Diary, FireBaseError>) -> Void) {

        dataBase.collection(Collection.diaries.rawValue).document(diaryId).getDocument { (document, error) in

            guard let document = document, document.exists else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }

            do {
                if let diary = try document.data(as: Diary.self, decoder: Firestore.Decoder()) {
                    completion(.success(diary))
                }
            } catch {
                completion(.failure(FireBaseError.gotFirebaseError(error)))
            }
        }
    }

    func fetchPetAllDiaries(petId: String, completion: @escaping (Result<[Diary], FireBaseError>) -> Void) {

        var documentsRef = dataBase.collection(Collection.diaries.rawValue)
            .whereField("petId", isEqualTo: petId)
            .order(by: "createdTime", descending: true)
            .limit(to: 10)

        if let petDiaryPagingLastDoc = petDiaryPagingLastDoc {
            documentsRef = documentsRef.start(afterDocument: petDiaryPagingLastDoc)
        }

        documentsRef.getDocuments { (querySnapshot, error) in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }

            self.petDiaryPagingLastDoc = querySnapshot.documents.last
            let diaries = querySnapshot.documents.compactMap({
                try? $0.data(as: Diary.self)
            })
            completion(.success(diaries))
        }
    }

    func fetchDiaries(completion: @escaping (Result<[Diary], FireBaseError>) -> Void) {

        var documentsRef = dataBase.collection(Collection.diaries.rawValue)
            .whereField("userId", isEqualTo: FirebaseManager.userId)
            .order(by: "createdTime", descending: true)
            .limit(to: 10)

        if let userDiaryPagingLastDoc = userDiaryPagingLastDoc {
            documentsRef = documentsRef.start(afterDocument: userDiaryPagingLastDoc)
        }

        documentsRef.getDocuments { (querySnapshot, error) in

            guard let querySnapshot = querySnapshot else {
                print("Error fetching document: \(error!)")
                completion(.failure(FireBaseError.gotFirebaseError(error!)))
                return
            }

            self.userDiaryPagingLastDoc = querySnapshot.documents.last
            let diaries = querySnapshot.documents.compactMap({
                try? $0.data(as: Diary.self)
            })
            completion(.success(diaries))
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
