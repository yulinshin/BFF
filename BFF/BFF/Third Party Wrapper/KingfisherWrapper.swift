//
//  KingfisherWrapper.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit
import Kingfisher

extension UIImageView {

    func loadImage(_ urlString: String?, placeHolder: UIImage? = nil) {

        guard urlString != nil else { return }

        let url = URL(string: urlString!)

        self.kf.setImage(with: url, placeholder: placeHolder)
    }

}
