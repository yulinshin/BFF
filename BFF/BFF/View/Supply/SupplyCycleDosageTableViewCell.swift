//
//  SupplyCycleDosageTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class SupplyCycleDosageTableViewCell: UITableViewCell {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var cycleDosageTextfield: UITextField!

    var callbackCycleUnit: ((_ unit: String) -> Void)?

    var callbackCycleDosage: ((_ dosage: Int) -> Void)?

    static let identifier = "SupplyCycleDosageTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        segment.addTarget(self, action: #selector(onChange), for: .valueChanged)
        cycleDosageTextfield.delegate = self


    }

    @objc func onChange(sender: UISegmentedControl) {

        guard let unit = sender.titleForSegment(
            at: sender.selectedSegmentIndex) else { return }

        callbackCycleUnit?(unit)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }

}

extension SupplyCycleDosageTableViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        let text = textField.text ?? ""
        callbackCycleDosage?(Int(text) ?? 0)

    }

}
