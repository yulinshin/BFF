//
//  CommentViewModel.swift
//  BFF
//
//  Created by yulin on 2021/11/6.
//

import Foundation
import Kingfisher
import SwiftUI

class ChatListViewModel { // For ListTableViewController

    var messages = Box([Message]())


    var didGetData: (() -> Void)?
    var showingUserList = Box([ChatGroupViewModel]())
    var contactList  = [String]()

    init(updateNotify: @escaping (() -> Void)) {
        self.didGetData = updateNotify
        getChatData()
    }
    func getChatData() {

        FirebaseManager.shared.listenAllMessages { result in
            switch result {

            case .success(let messages):

                self.messages.value = messages
         
                messages.forEach { message in

                    if !self.contactList .contains(message.sender) {
                        self.contactList .append(message.sender) // If is sender is new Contact, Add to List
                    }
                    if !self.contactList .contains(message.receiver){
                        self.contactList .append(message.receiver) // If is receiver is new Contact, Add to List
                    }

                }

                self.showingUserList.value = [ChatGroupViewModel]() // CleaUp the List Array
                self.contactList .forEach { contactId in
                    if contactId != FirebaseManager.shared.userId { // Remove Self from list array
                    let group = messages.filter { $0.receiver == contactId || $0.sender == contactId } // merge same Contact in One group
                    let groupModel = ChatGroupViewModel(messages: group, userId: contactId)
                    self.showingUserList.value.append(groupModel) // Add fetched Contact List
                    }
                }

                self.didGetData?() // NotifyView to update List

            case .failure(let error):
                print("ERROR:::::\(error)")

            }
        }

    }
}

class ChatGroupViewModel { // For ListTableViewCell & ChatTableViewController
    let messages = Box([Message]())
    let lastMassage = Box(" ")
    let userId = Box(" ")
    let lastMassageDate = Box(" ")
    let userName = Box(" ")
    let userPic = Box(" ")
    var didGetData: (() -> Void)?

    init (messages: [Message], userId: String) {

        self.messages.value = messages.sorted(by: {$0.createdTime.dateValue() > $1.createdTime.dateValue()})
        self.userId.value = userId
        guard let content = self.messages.value.first?.content,
        let lastDate = self.messages.value.first?.createdTime.dateValue().toString() else { return }
            self.lastMassage.value = content
            self.lastMassageDate.value = lastDate
        getUserInfo(userId: userId)

        }

    init (userid: String) {
        self.userId.value = userid
        getUserInfo(userId: userid)
    }

    func setlisiten() {

        FirebaseManager.shared.listenMessages(otherUserId: self.userId.value) { result in
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
    func getUserInfo(userId: String) {

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

class ChatViewModel { // For ChatTableViewCell

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

    func getUserInfo(userId: String) {

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
