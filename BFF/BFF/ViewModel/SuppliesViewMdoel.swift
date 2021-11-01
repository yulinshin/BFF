//
//  SupplesViewMdoel.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import Foundation

class SuppliesViewMdoel {

    let suppiesViewModel = Box([SupplyViewModel]())
    var suppiesDidChange: (() -> Void)?

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
                self.suppiesViewModel.value = newViewModels
                self.suppiesDidChange?()

            case .failure(let error):
                print(error)
            }
        }
    }

}
