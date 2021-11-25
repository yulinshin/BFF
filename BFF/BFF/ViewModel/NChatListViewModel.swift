//
//  NChatListViewModel.swift
//  BFF
//
//  Created by yulin on 2021/11/19.
//

import Foundation
import Network
import Kingfisher

class ChatListVM {

    var data = Box([MessageGroup]())
    var chatGroupList = Box([ChatGroupVM]())
    var showingList = Box([ChatGroupVM]())

    var didUpdateShowingData: (() -> Void )?

    init(upDataNotify: @escaping(() -> Void)) {
        self.didUpdateShowingData = upDataNotify
        listenMessageGroup()
    }

    func listenMessageGroup() {

        FirebaseManager.shared.listenMessageGroup { result in

            switch result {

            case .success(let groups):

                self.data.value = groups

                self.coverToGroupVM()

            case .failure(let error):

                print(error)

            }
        }
    }

    func coverToGroupVM() {

        var groupVMs = [ChatGroupVM]()

        self.data.value.forEach { groupData in
            var otherUserId: String {
               var user = ""
               groupData.users.forEach { userId in
                if userId != FirebaseManager.userId {
                    user = userId
                }
            }
               return user
           }
            let groupVM = ChatGroupVM(groupId: groupData.groupId, otherUserId: otherUserId)
            groupVMs.append(groupVM)
        }

        self.chatGroupList.value = groupVMs
        filterBlockUser()

    }

    func filterBlockUser() {

        self.showingList.value = self.chatGroupList.value.filter({ chatGroupVM in

            if let blockUsers = FirebaseManager.shared.currentUser?.blockUsers {
                return !blockUsers.contains(chatGroupVM.otherUserId.value)
            } else {
                return true
            }
        })

        self.showingList.value = self.showingList.value.filter({ chatGroupVM in

            if chatGroupVM.lastContent.value == "" {
                return false
            } else {
                return true
            }


        })


        self.didUpdateShowingData?()
    }

}

class ChatGroupVM {

    var messageData = Box([Message]())
    var chatVMs = Box([ChatVM]())
    var groupId = Box("")
    var otherUserId = Box("")
    var otherUserName = Box("")
    var otherUsrPic = Box("")
    var lastContent = Box("")
    var lastCreatedTime = Box("")
    var didChatUpdate: (() -> Void)?

    init (groupId: String, otherUserId: String) {

        self.groupId.value = groupId
        self.otherUserId.value = otherUserId
        getOtherUserInfo()
        listenMessageFromGroup()

    }

    init (otherUserId: String) {

        self.otherUserId.value = otherUserId
        getOtherUserInfo()
        listenMessageFromUserId()
    }

    func listenMessageFromUserId() {


        FirebaseManager.shared.listenMessageFromUserID(otherUseId: self.otherUserId.value) { result in
            switch result {

            case .success(let data):
                self.messageData.value = data.messages.sorted(by: { $0.createdTime.dateValue() < $1.createdTime.dateValue() })
                self.groupId.value = data.groupId
                self.getLastChat()
                self.coverToVM()


            case .failure(let error):
                print(error)

            }
        }
    }


    func listenMessageFromGroup() {

        guard groupId.value != "" else { return }

        FirebaseManager.shared.listenMessageFromGroup(groupId: groupId.value) { result in

            switch result {

            case .success(let messages):

                self.messageData.value = messages.sorted(by: { $0.createdTime.dateValue() < $1.createdTime.dateValue() })

                self.getLastChat()
                self.coverToVM()

            case .failure(let error):
                print(error)

            }
        }
    }

    func getLastChat() {

        guard let lastChat = messageData.value.last else {
            return
        }

        self.lastContent.value = lastChat.content
        self.lastCreatedTime.value = lastChat.createdTime.dateValue().toString()

    }

    func getOtherUserInfo() {
        FirebaseManager.shared.fetchUserInfo(userId: self.otherUserId.value) { result in

            switch result {

            case .success(let user):

                self.otherUserName.value = user.userName
                self.otherUsrPic.value = user.userThumbNail?.url ?? ""

            case .failure(let error):
                print("Can't Get \(self.otherUserId.value) UserInfo \(error)")

            }
        }
    }

    func coverToVM() {

        var chatVMs = [ChatVM]()

        self.messageData.value.forEach { message in

            let chatVM = ChatVM(
                userId: message.sender,
                otherUserPic: otherUsrPic.value,
                content: message.content)

            chatVMs.append(chatVM)
        }

        self.chatVMs.value = chatVMs
        self.didChatUpdate?()

    }

}

class ChatVM {

    var userId = Box("")
    var content = Box("")

    init(userId: String, otherUserPic: String, content: String) {
        self.userId.value = userId
        self.content.value = content
    }
}
