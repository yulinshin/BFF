//
//  DairyPhotoCellViewModel.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import Foundation

struct PhotoCellViewModel {

    let imageUrl: String

    init(with model: String) {
        imageUrl = model
    }

}
