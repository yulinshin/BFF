//
//  PetInfoTableTableViewCell.swift
//  BFF
//
//  Created by yulin on 2021/10/20.
//

import UIKit

class PetInfoTableTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!

    static let identifier = "PetInfoTableTableViewCell"

    var callback: ((_ text: String) -> Void)?
    var moreButtonTap: (() -> Void)?
    let datePicker = UIDatePicker()
    let picker = UIPickerView()
    var pickerData = [String]() {

        didSet {
            picker.reloadAllComponents()
        }

    }

    enum CellStyle {
        case textfield
        case more
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.isHidden = true
        textField.borderStyle = .none
        button.isHidden = true
        // Initialization code
    }

    func configur(cellStyle: CellStyle, title: String, button: String = "") {

        titleLabel.text = title

        textField.delegate = self

        switch cellStyle {
        case .textfield:
            self.textField.isHidden = false
            self.textField.placeholder = title

        case .more:
            self.button.isHidden = false
            self.button.setTitle("", for: .normal)
            self.button.setImage(UIImage(systemName: "pencil"), for: .normal)
        }

    }

    @IBAction func tapButton(_ sender: Any) {
        moreButtonTap?()
    }

    func creatDatePicker () {

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedFromDate))

        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]

         let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([leftSpace, doneBtn], animated: true)

        textField.inputAccessoryView = toolbar

        textField.inputView = datePicker

        datePicker.datePickerMode = .date

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        }

    }

  @objc func donePressedFromDate() {

      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      textField.text = formatter.string(from: datePicker.date)
      textField.resignFirstResponder()

    }

    @objc func donePressedFromPicker() {

        textField.resignFirstResponder()

      }

    func creatPicker(pickerData: [String]) {

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedFromPicker))

        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]

         let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([leftSpace, doneBtn], animated: true)

        textField.inputAccessoryView = toolbar
        textField.inputView = picker
        picker.delegate = self
        picker.dataSource = self
        self.pickerData = pickerData

    }

}

extension PetInfoTableTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1

    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return pickerData[row]

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = pickerData[row]
    }

}

extension PetInfoTableTableViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        guard let text = textField.text else { return }
        callback?(text)

    }

}
