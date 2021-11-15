//
//  CommentViewModel.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import Foundation
import Kingfisher
import SwiftUI

class ChatListViewModel {

    var messages = Box([Message]())


    var didGetData: (() -> Void)?
    var showingUserList = Box([ChatGroupViewModel]())
    var conetentList = [String]()


    init(updateNotify: @escaping (()->Void)) {
        self.didGetData = updateNotify
        getChatData()
    }
    func getChatData() {

        FirebaseManager.shared.listMessages { result in
            switch result {

            case .success(let messages):

                self.messages.value = messages
         
                messages.forEach { message in

                    if !self.conetentList.contains(message.sender) {
                        self.conetentList.append(message.sender)
                    } else if !self.conetentList.contains(message.receiver){
                        self.conetentList.append(message.receiver)
                    }

                }
                self.showingUserList.value = [ChatGroupViewModel]()
                self.conetentList.forEach { conetentId in
                    if conetentId != FirebaseManager.shared.userId {
                    let group = messages.filter{ $0.receiver == conetentId || $0.sender == conetentId}
                    let groupModel = ChatGroupViewModel(messages: group, userId: conetentId)
                    self.showingUserList.value.append(groupModel)
                    }
                }

                self.didGetData?()

            case .failure(let error):
                print("ERROR:::::\(error)")


            }
        }

    }
}


class ChatGroupViewModel {
    let messages = Box([Message]())
    let lastMassage = Box(" ")
    let userId = Box(" ")
    let lastMassageDate = Box(" ")
    let userName = Box(" ")
    let userPic = Box(" ")
    var didGetData: (() -> Void)?

    init (messages:[Message], userId: String){

        self.messages.value = messages.sorted(by: {$0.createdTime.dateValue() > $1.createdTime.dateValue()})
        self.userId.value = userId
        self.userName.value = "" //Need to cahnge to userName
        self.userPic.value = ""  //Need to cahnge to userName
        guard let content = self.messages.value.first?.content,
        let lastDate = self.messages.value.first?.createdTime.dateValue().toString() else { return }
            self.lastMassage.value = content
            self.lastMassageDate.value = lastDate
        getUserInfo(userId: userId)
        }

    init (userid:String){
        self.userId.value = userid
        getUserInfo(userId: userid)
    }

    func setlisiten(){

        FirebaseManager.shared.listMessages(otherUserId: self.userId.value) { result in
            switch result {

            case .success(let messages):

                self.messages.value = messages
                self.didGetData?()

            case .failure(let error):
                print(error)


            }
        }
        getUserInfo(userId: userId.value)
    }
    func getUserInfo(userId:String){

        FirebaseManager.shared.fetchUserInfo(userId: userId) { result in
            switch result {

            case .success(let user):

                self.userName.value = user.userName
                self.userPic.value = user.userThumbNail?.url ?? ""
                self.didGetData?()

            case .failure(let error):
                print(error)


            }
        }

    }

}


class ChatViewModel {

    let content = Box(" ")
    let date = Box(" ")
    let recevier = Box(" ")
    let sender = Box(" ")
    let userName = Box(" ")
    let userPic = Box(" ")

    init(from message: Message) {
        getMessageData(from: message)
        getUserInfo(userId: message.sender)
    }
    func getMessageData(from message: Message) {

        self.content.value = message.content
        self.date.value = message.createdTime.dateValue().toString()
        self.recevier.value = message.receiver
        self.sender.value = message.sender


    }

    func getUserInfo(userId:String){

        FirebaseManager.shared.fetchUserInfo(userId: userId) { result in
            switch result {

            case .success(let user):

                self.userName.value = user.userName
                self.userPic.value = user.userThumbNail?.url ?? ""

            case .failure(let error):
                print(error)


            }
        }

    }

}


