//
//  WellcomeCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/18.
//

import UIKit

class WellcomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var addDiaryButton: UIButton!

    var creatButtonTap: (() -> Void)?

    func setup(userName: String, petsCount: Int) {

        titleLabel.text = "HI \(userName)!"

        switch petsCount {
        case 0:
            subTitleLabel.text = "來新增一個毛小孩的寵物日誌吧!"
            addDiaryButton.isHidden = true
        case 1:
            subTitleLabel.text = "來紀錄一下小孩子又做了什麼好事吧!"
            addDiaryButton.isHidden = false
        default:
            subTitleLabel.text = "來紀錄一下小孩子們又做了什麼好事吧!"
            addDiaryButton.isHidden = false
        }

    }
    @IBAction func creatButtonTap(_ sender: Any) {
        creatButtonTap?()
    }
}
