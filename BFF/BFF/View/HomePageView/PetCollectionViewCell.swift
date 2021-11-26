//
//  PetCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit
import Kingfisher
import Lottie


class PetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var diaryCardBackground: UIView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var petKindIcon: UIImageView!

    static var identifier = "PetCollectionViewCell"
    var didTapCard: (() -> Void)?
    let addPetAnimationView = AnimationView(name: "AddPet")
    let title = UILabel()


    func setup(petImage: String, petName: String, petBirthday: String) {
        addPetAnimationView.isHidden = true
        title.isHidden = true
        birthdayLabel.isHidden = false
        petImageView.isHidden = false
        petNameLabel.isHidden = false
        petImageView.isHidden = false
        petKindIcon.isHidden = false
        petImageView.loadImage(petImage)
        petImageView.contentMode = .scaleAspectFill
        petImageView.layer.cornerRadius = 16
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.tapCard))
        petImageView.addGestureRecognizer(tapGR)
        petImageView.isUserInteractionEnabled = true
        diaryCardBackground.layer.cornerRadius = 20
        diaryCardBackground.layer.shadowColor = UIColor.gray.cgColor
        diaryCardBackground.layer.shadowOffset = CGSize(width: 2, height: 2)
        diaryCardBackground.layer.shadowOpacity = 0.4
        diaryCardBackground.layer.shadowRadius = 6
        petNameLabel.text = petName
        birthdayLabel.text = calculateBirthday(petBirthday: petBirthday)
    }

    func calculateBirthday(petBirthday: String) -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        guard let date = dateFormatter.date(from: petBirthday) else { return "" }
        let now = Date()
        let ageComponents = Calendar.current.dateComponents([.year, .month], from: date, to: now)
        if let age = ageComponents.year,
           age > 0 {
            if let month = ageComponents.month,
            month > 0 {
               return "\(age)歲\(month)個月"
            } else {
                return "\(age)歲"
            }
        } else {
            if let month = ageComponents.month,
            month > 0 {
               return "\(month)個月"
            } else {
                  return "0個月"
                }
            }
    }

    func setupBlankDiaryBook() {
        petKindIcon.isHidden = true
        petImageView.isHidden = true
        petNameLabel.isHidden = true
        addPetAnimationView.isHidden = false
        addPetAnimationView.frame = diaryCardBackground.frame
        birthdayLabel.isHidden = true

        diaryCardBackground.addSubview(addPetAnimationView)
        diaryCardBackground.addSubview(title)

        addPetAnimationView.translatesAutoresizingMaskIntoConstraints = false
        addPetAnimationView.topAnchor.constraint(equalTo: diaryCardBackground.topAnchor, constant: 60).isActive = true
        addPetAnimationView.centerXAnchor.constraint(equalTo: diaryCardBackground.centerXAnchor).isActive = true
        addPetAnimationView.heightAnchor.constraint(equalToConstant: 300).isActive = true

        let keyPath = AnimationKeypath(keys: ["**", "Fill 1", "**", "Color"])

        let colorProvider = ColorValueProvider(UIColor.mainColor.lottieColorValue)
        addPetAnimationView.setValueProvider(colorProvider, keypath: keyPath)

        addPetAnimationView.center = diaryCardBackground.center
        addPetAnimationView.contentMode = .scaleAspectFit
        addPetAnimationView.loopMode = .loop
        addPetAnimationView.play()

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.tapCard))
        addPetAnimationView.addGestureRecognizer(tapGR)
        addPetAnimationView.isUserInteractionEnabled = true

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
