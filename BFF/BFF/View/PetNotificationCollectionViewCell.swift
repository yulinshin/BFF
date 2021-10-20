//
//  PetNotificationCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit
import Kingfisher

class PetNotificationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var petThumbnailImageView: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    func setup(petName: String, content: String, petImage: String ) {
        petThumbnailImageView.loadImage(petImage, placeHolder: UIImage(systemName: "person.fill"))
        contentLabel.text = content
        petNameLabel.text = petName
        petThumbnailImageView.layer.cornerRadius = petThumbnailImageView.frame.height / 2
    }
    
}
