//
//  AddNewItemTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class AddNewItemTableViewCell: UITableViewCell {
    @IBOutlet weak var cellCardBackGroundVIew: UIView!

    static let identifier = "AddNewItemTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        // Layout

        cellCardBackGroundVIew.layer.shadowColor = UIColor.gray.cgColor
        cellCardBackGroundVIew.layer.shadowOpacity = 0.4
        cellCardBackGroundVIew.layer.cornerRadius = 20
        cellCardBackGroundVIew.layer.shadowRadius = 10
        cellCardBackGroundVIew.backgroundColor = UIColor.white

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
