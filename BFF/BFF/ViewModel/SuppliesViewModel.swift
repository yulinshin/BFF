//
//  SupplesViewMdoel.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import Foundation

class SuppliesViewModel {

    let suppliesViewModel = Box([SupplyViewModel]())
    var suppliesDidChange: (() -> Void)?

    init() {
       fetchSuppliesData()
    }

    func fetchSuppliesData() {

        print("Start fetch supplies data")

        FirebaseManager.shared.fetchSupplies { result in

            var newViewModels = [SupplyViewModel]()
            switch result {
            case .success(let supplies):

                supplies.forEach { supply in
                    print("Supply: \(supply)")

                    let supplyViewModel = SupplyViewModel(from: supply)
                    newViewModels.append(supplyViewModel)
                }
                self.suppliesViewModel.value = newViewModels
                self.suppliesDidChange?()

            case .failure(let error):
                print(error)
            }
        }
    }

}
