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
    @IBOutlet weak var diaryCardBackground: UIView!

    var didTapCard: (() -> Void)?

    func setup(petImage: String) {
        petImageView.loadImage(petImage)
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.cornerRadius = 20
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.tapCard))
        petImageView.addGestureRecognizer(tapGR)
        petImageView.isUserInteractionEnabled = true
        diaryCardBackground.layer.cornerRadius = 20
        diaryCardBackground.layer.shadowColor = UIColor.gray.cgColor
        diaryCardBackground.layer.shadowOffset = CGSize(width: 2, height: 2)
        diaryCardBackground.layer.shadowOpacity = 0.4
        diaryCardBackground.layer.shadowRadius = 6

    }

    func setupBlankDiaryBook() {

        petImageView.image = UIImage(named: "")
        petImageView.contentMode = .scaleAspectFit
        petImageView.layer.cornerRadius = 20

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.tapCard))
        petImageView.addGestureRecognizer(tapGR)
        petImageView.isUserInteractionEnabled = true

        diaryCardBackground.layer.cornerRadius = 20
        diaryCardBackground.layer.shadowColor = UIColor.gray.cgColor
        diaryCardBackground.layer.shadowOffset = CGSize(width: 2, height: 2)
        diaryCardBackground.layer.shadowOpacity = 0.4
        diaryCardBackground.layer.shadowRadius = 6
    }

    @objc func tapCard() {

        didTapCard?()

    }

}
