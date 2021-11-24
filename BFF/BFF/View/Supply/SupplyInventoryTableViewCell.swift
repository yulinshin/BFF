//
//  SupplyInventoryTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit

class SupplyInventoryTableViewCell: UITableViewCell {

    @IBOutlet weak var maxStockTextField: UITextField!

    @IBOutlet weak var stockTextField: UITextField!

    @IBOutlet weak var unitTextField: UITextField!

    static let identifier = "SupplyInventoryTableViewCell"

    var callbackMaxStock: ((_ maxStock: Int) -> Void)?
    var callbackStock: ((_ stock: Int) -> Void)?
    var callbackUnit: ((_ unit: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        maxStockTextField.delegate = self
        stockTextField.delegate = self
        unitTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}

extension SupplyInventoryTableViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        let text = textField.text ?? ""

        switch textField {

        case maxStockTextField:

            callbackMaxStock?(Int(text) ?? 0)

        case stockTextField:

            callbackStock?(Int(text) ?? 0)

        case unitTextField:

            callbackUnit?(text)

        default:

            return

        }
    }
}
