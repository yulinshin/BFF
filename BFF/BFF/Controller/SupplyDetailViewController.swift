//
//  SupplyDetailViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit
import SwiftUI

class SupplyDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creatButton: UIButton!


    enum ConstrolleMode {
        case create
        case edit
    }

    enum CellStyle {

        case icon
        case name
        case inventory
        case pets
        case cycleDosage
        case reminder

    }

    var mode: ConstrolleMode = .create

    var cellArray: [CellStyle] = [.icon, .name, .inventory, .pets, .cycleDosage, .reminder]

    var userPetsData = [Pet]() {
        didSet{
            tableView.rectForRow(at: IndexPath.init(row: 3, section: 0))
        }
    }
    
    var viewModel = SupplyViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        switch mode {

        case .create:

            creatButton.setTitle("新增", for: .normal)
            
        case .edit:
            creatButton.setTitle("儲存", for: .normal)

        }


    }

    @objc func creatSupply() {

        // swiftlint:disable:next line_length
        let supply = Supply(color: viewModel.iconColor.value, cycleTime: viewModel.cycleTime.value, forPets: viewModel.supplyUseByPets.value, fullStock: viewModel.maxInventory.value, iconImage: viewModel.supplyIconImage.value, isReminder: viewModel.isNeedToRemind.value, perCycleTime: viewModel.cycleDosage.value, reminderPercent: viewModel.remindPercentage.value, stock: viewModel.reminingInventory.value, supplyId: "supplyID", supplyName: viewModel.supplyName.value, unit: viewModel.supplyUnit.value)

        FirebaseManager.shared.creatSupply(supply: supply)
    }

    @objc func updateSupply() {

        // swiftlint:disable:next line_length
        let supply = Supply(color: viewModel.iconColor.value, cycleTime: viewModel.cycleTime.value, forPets: viewModel.supplyUseByPets.value, fullStock: viewModel.maxInventory.value, iconImage: viewModel.supplyIconImage.value, isReminder: viewModel.isNeedToRemind.value, perCycleTime: viewModel.cycleDosage.value, reminderPercent: viewModel.remindPercentage.value, stock: viewModel.reminingInventory.value, supplyId: viewModel.supplyId.value, supplyName: viewModel.supplyName.value, unit: viewModel.supplyUnit.value)

        FirebaseManager.shared.updateSupply(supplyId: supply.supplyId, data: supply)
    }
    @IBAction func tapButton(_ sender: Any) {

        switch mode {
        case .create:
            creatSupply()
        case .edit:
            updateSupply()
        }
    }


}

// MARK: - TableViewDataSource

extension SupplyDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch cellArray[indexPath.row] {

        case .icon:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyIconCellTableViewCell.identifier, for: indexPath) as? SupplyIconCellTableViewCell else { return UITableViewCell() }

            viewModel.supplyIconImage.bind { icon in
                cell.iconImage.image = UIImage(systemName: icon)
            }

            viewModel.iconColor.bind { color in
                cell.iconImage.backgroundColor = UIColor(named: color)
            }

            viewModel.maxInventory.bind { maxStock in
                self.viewModel.reminingInventory.bind { stock in
                    cell.stockLabel.text = "\(maxStock)/\(stock)"
                }
            }



            cell.iconNameCallback = { name in

                self.viewModel.supplyIconImage.value = name

            }

            cell.iconColorCallback = { color in
                self.viewModel.iconColor.value = color
            }

            return cell

        case .name:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyNameTableViewCell.identifier, for: indexPath) as? SupplyNameTableViewCell else { return UITableViewCell() }


            viewModel.supplyName.bind { name in
                cell.textField.text = name
            }

            cell.callback = {name in

                self.viewModel.supplyName.value = name

            }

            return cell

        case .inventory:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyInventoryTableViewCell.identifier, for: indexPath) as? SupplyInventoryTableViewCell else { return UITableViewCell() }

            viewModel.maxInventory.bind { maxStock in
                cell.maxStockTextField.text = "\(maxStock)"
            }

            viewModel.reminingInventory.bind { stock in
                cell.stockTextField.text = "\(stock)"
            }

            viewModel.supplyUnit.bind { unit in
                cell.unitTextField.text = unit
            }

            cell.callbackMaxStock = { maxStock in
                self.viewModel.maxInventory.value = maxStock
            }

            cell.callbackStock = { stock in
                self.viewModel.reminingInventory.value = stock
            }

            cell.callbackUnit = { unit in
                self.viewModel.supplyUnit.value = unit
            }

            return cell

        case .pets:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyPetsTableViewCell.identifier, for: indexPath) as? SupplyPetsTableViewCell else { return UITableViewCell() }


            viewModel.supplyUseByPets.bind { pets in
                cell.userPetsData = self.userPetsData
                cell.pets = pets
            }


            cell.callback = { pets in
                self.viewModel.supplyUseByPets.value = pets
            }


            return cell

        case .cycleDosage:

            // swiftlint:disable:next line_length
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyCycleDosageTableViewCell.identifier, for: indexPath) as? SupplyCycleDosageTableViewCell else { return UITableViewCell() }

            viewModel.cycleDosage.bind { number in
                cell.cycleDosageTextfield.text = "\(number)"

            }

            cell.callbackCycleUnit = { unit in

                self.viewModel.supplyUnit.value = unit

            }

            cell.callbackCycleDosage = { dosage in

                self.viewModel.cycleDosage.value = dosage

            }

            return cell

        case .reminder:

            // swiftlint:disable:next line_length
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyReminderCellTableViewCell.identifier, for: indexPath) as? SupplyReminderCellTableViewCell else { return UITableViewCell() }

            viewModel.isNeedToRemind.bind { isNeedToRemind in
                cell.switchTogle.isOn = isNeedToRemind
            }

            viewModel.remindPercentage.bind { remindPercentage in
                cell.reminderTextFIeld.text = "\(remindPercentage)"
            }

            cell.callbackTogle = { isNeedToRemind in
                self.viewModel.isNeedToRemind.value = isNeedToRemind
            }

            cell.callbackRemindPercentage = { percentage in
                self.viewModel.remindPercentage.value = percentage

            }

            return cell

        }
    }

}

// MARK: - TableViewDelegate

extension SupplyDetailViewController: UITableViewDelegate {

}
