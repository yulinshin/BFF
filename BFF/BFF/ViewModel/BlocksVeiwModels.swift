//
//  BlocksVeiwModels.swift
//  BFF
//
//  Created by yulin on 2021/11/12.
//

import Foundation

class BlocksViewModelList {

    var blocks = Box([BlocksViewModel]())
    var didUpdateData: (() -> Void)?

    init(userId: String) {

        FirebaseManager.shared.fetchCurrentUserInfo { result in

            switch result {

            case .success(let user):

                guard let blocks = user.blockUsers else { return }
                blocks.forEach { userId in

                    let block =  BlocksViewModel(userId: userId)
                    block.didUpdateData = {
                        self.blocks.value.append(block)
                        self.didUpdateData?()
                    }
                }

            case .failure(let error):
                print(error)

            }
        }
    }


    func unBlock(indexPath: Int){

        FirebaseManager.shared.unblockUser(blockUserId: self.blocks.value[indexPath].id.value)
        blocks.value.remove(at: indexPath)
        self.didUpdateData?()

    }
}

class BlocksViewModel {

    var image = Box(" ")
    var name = Box(" ")
    var id = Box(" ")
    var didUpdateData: (() -> Void)?

    init(userId: String){

        self.id.value = userId

        FirebaseManager.shared.fetchUserInfo(userId: userId) { result in

            switch result {

            case .success(let user):

                self.image.value = user.userThumbNail?.url ?? ""
                self.name.value = user.userName
                self.didUpdateData?()

            case .failure(let error):

                print(error)

            }

        }

    }


}
