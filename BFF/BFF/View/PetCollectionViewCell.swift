//
//  PetCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit
import Kingfisher

class PetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var petImageView: UIImageView!

    func setup(petImage: String) {
        petImageView.loadImage(petImage)
    }

}
