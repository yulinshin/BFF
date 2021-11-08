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
        petNameLabel.text = petName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        guard let date = dateFormatter.date(from:petBirthday) else { return }
        let now = Date()

        let ageComponents = Calendar.current.dateComponents([.year, .month], from: date, to: now)
        if let age = ageComponents.year {
            if let month = ageComponents.month{
                birthdayLabel.text = "\(age)歲\(month)個月"
            }else{
                birthdayLabel.text = "\(age)歲"
            }
        } else {
            if let month = ageComponents.month{
                birthdayLabel.text = "\(month)個月"
            }else {

                    birthdayLabel.text = "0個月"
                }
            }
    }




    func setupBlankDiaryBook() {
        title.isHidden = false
        petImageView.isHidden = true
        petNameLabel.isHidden = true
        addPetAnimationView.isHidden = false
        addPetAnimationView.frame = diaryCardBackground.frame
        birthdayLabel.isHidden = true


        diaryCardBackground.addSubview(addPetAnimationView)
        diaryCardBackground.addSubview(title)

        title.translatesAutoresizingMaskIntoConstraints = false
        title.bottomAnchor.constraint(equalTo: diaryCardBackground.bottomAnchor, constant: -80).isActive = true
        title.leadingAnchor.constraint(equalTo: diaryCardBackground.leadingAnchor, constant: 40).isActive = true
        title.trailingAnchor.constraint(equalTo: diaryCardBackground.trailingAnchor, constant: -30).isActive = true
        title.heightAnchor.constraint(equalToConstant: 24).isActive = true

        title.text = "新增毛小孩"
        title.textAlignment = .center
        title.textColor = UIColor(named: "main")
        title.font = .systemFont(ofSize: 16, weight: .bold)

        addPetAnimationView.translatesAutoresizingMaskIntoConstraints = false
        addPetAnimationView.topAnchor.constraint(equalTo: diaryCardBackground.topAnchor, constant: 60).isActive = true
        addPetAnimationView.bottomAnchor.constraint(equalTo: title.topAnchor, constant: -10).isActive = true
        addPetAnimationView.centerXAnchor.constraint(equalTo: diaryCardBackground.centerXAnchor).isActive = true
        addPetAnimationView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        let keypath = AnimationKeypath(keys: ["**", "Fill", "**", "Color"])
        if let color = UIColor(named: "main") {
            let colorProvider = ColorValueProvider(color.lottieColorValue)
            addPetAnimationView.setValueProvider(colorProvider, keypath: keypath)
        }
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
