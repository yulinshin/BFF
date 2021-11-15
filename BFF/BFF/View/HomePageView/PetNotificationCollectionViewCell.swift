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
    @IBOutlet weak var notificationCard: UIView!

    var didTapCancle: (() -> Void)?
    
    func setup(petName: String, content: String, petImage: String ) {
        petThumbnailImageView.loadImage(petImage, placeHolder: UIImage(systemName: "person.fill"))
        contentLabel.text = content
        petNameLabel.text = petName

    }

    override func layoutSubviews() {
        petThumbnailImageView.layer.cornerRadius = petThumbnailImageView.frame.height/2
        petThumbnailImageView.clipsToBounds = true


        notificationCard.layer.cornerRadius = 10
        notificationCard.layer.shadowColor = UIColor(named: "main")?.cgColor
        notificationCard.layer.shadowOffset = CGSize(width: 2, height: 2)
        notificationCard.layer.shadowOpacity = 0.5
        notificationCard.layer.shadowRadius = 6
      }

    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        
        self.didTapCancle?()

    }
}
