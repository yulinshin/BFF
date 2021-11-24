//
//  bookViewModel.swift
//  BFF
//
//  Created by yulin on 2021/11/3.
//

import Foundation
import Kingfisher

class BookViewModel {

    var icon = Box(" ")
    var title = Box(" ")
    var subtitle = Box(" ")

    init(icon: String, title: String, subtitle: String) {

        self.icon.value = icon
        self.title.value = title
        self.subtitle.value = subtitle

    }


}
