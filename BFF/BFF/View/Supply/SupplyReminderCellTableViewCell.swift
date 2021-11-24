//
//  SupplyReminderCellTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class SupplyReminderCellTableViewCell: UITableViewCell {

    @IBOutlet weak var switchToggle: UISwitch!
    @IBOutlet weak var reminderTextFIeld: UITextField!

    static let identifier = "SupplyReminderCellTableViewCell"

    var callbackToggle: ((_ isNeedToRemind: Bool) -> Void)?

    var callbackRemindPercentage: ((_ percentage: Double) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        reminderTextFIeld.delegate = self
        switchToggle.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   @objc func onSwitchValueChanged(_ switch: UISwitch) {

       if switchToggle.isOn {
           callbackToggle?(true)
       } else {
           callbackToggle?(false)
       }
    }

}

extension SupplyReminderCellTableViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        let text = textField.text ?? ""
        callbackRemindPercentage?(Double(text) ?? 0)

    }

}
