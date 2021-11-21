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
    var didTapSupplyNotification: ((String) -> ())?
    var didTapCommentNotification: ((String) -> ())?
    var viewModel: NotificationViewModel?
    func setup(viewModel: NotificationViewModel) {

        self.viewModel = viewModel

        viewModel.petPicUrl.bind { url in
            self.petThumbnailImageView.loadImage(url, placeHolder: UIImage(systemName: "person.fill"))
        }

        viewModel.content.bind { content in
            self.contentLabel.text = content
        }

        viewModel.petName.bind { name in
            self.petNameLabel.text = name
        }
        notificationCard.isUserInteractionEnabled = true
        notificationCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNotification)))
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

    @objc func didTapNotification(){

        if viewModel?.type.value == "comment" {
            guard let diaryId = viewModel?.diaryId.value else { return }
            didTapCommentNotification?(diaryId)

        } else {
            guard let supplyId = viewModel?.supplyId.value else { return }
            didTapSupplyNotification?(supplyId)
        }

    }
}
