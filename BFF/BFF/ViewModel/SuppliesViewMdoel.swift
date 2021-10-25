//
//  SupplesViewMdoel.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import Foundation

class SuppliesViewMdoel {

    let suppiesViewModel = Box([SupplyViewModel]())

    init() {
       fetchSuppliesData()
    }

    func fetchSuppliesData() {

        print("Start fetch supplies data")

        FirebaseManager.shared.fetchSupplies { result in

            switch result {
            case .success(let supplies):

                supplies.forEach { supply in
                    print("Supply: \(supply)")
                    let supplyViewModel = SupplyViewModel(from: supply)
                    self.suppiesViewModel.value.append(supplyViewModel)
                }

            case .failure(let error):
                print(error)
            }
        }
    }
}
