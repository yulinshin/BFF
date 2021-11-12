//
//  BlocksVeiwModels.swift
//  BFF
//
//  Created by yulin on 2021/11/12.
//

import Foundation

class BlocksViewModelList {

    var blocks = Box([BlocksViewModel]())
    var didUpdateData: (()->Void)?

    init(userId: String){

        FirebaseManager.shared.fetchUser { result in


            switch result {

            case .success(let user):

                guard let blocks = user.blockPets else { return }
                blocks.forEach { petId in

                    let block =  BlocksViewModel(petId: petId)
                    block.didUpdateData = {
                        self.blocks.value.append(block)
                        self.didUpdateData?()
                    }
                }


            case .failure(let error):
                print (error)

            }
        }
    }


    func ubBlock(indexPath: Int){

        FirebaseManager.shared.unBlockPets(blockPetId: self.blocks.value[indexPath].id.value)
        blocks.value.remove(at: indexPath)
        self.didUpdateData?()

    }
}





class BlocksViewModel {

    var image = Box(" ")
    var name = Box(" ")
    var id = Box(" ")
    var didUpdateData: (()->Void)?

    init(petId: String){

        self.id.value = petId
        FirebaseManager.shared.fetchPet(petId: petId) { result in

            switch result {

            case .success(let pet):

                self.image.value = pet.petThumbnail?.url ?? ""
                self.name.value = pet.name
                self.didUpdateData?()

            case .failure(let error):

                print(error)

            }
        }
    }


}
