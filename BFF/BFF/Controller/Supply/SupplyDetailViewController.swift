//
//  SupplyDetailViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/26.
//

import UIKit
import Firebase

class SupplyDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIButton!


    enum ControllerMode {
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

    var mode: ControllerMode = .create

    var cellArray: [CellStyle] = [.icon, .name, .inventory, .pets, .cycleDosage, .reminder]

    var userPetsData = [Pet]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    var viewModel = SupplyViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        createButton.layer.cornerRadius = 10
        fetchData()

        switch mode {

        case .create:

            createButton.setTitle("新增", for: .normal)
            
        case .edit:
            createButton.setTitle("儲存", for: .normal)

        }

    }

    @objc func createSupply() {

        // swiftlint:disable:next line_length
        let supply = Supply(color: viewModel.iconColor.value, cycleTime: viewModel.cycleTime.value, forPets: viewModel.supplyUseByPets.value, fullStock: viewModel.maxInventory.value, iconImage: viewModel.supplyIconImage.value, isReminder: viewModel.isNeedToRemind.value, perCycleTime: viewModel.cycleDosage.value, reminderPercent: viewModel.remindPercentage.value, stock: viewModel.remainingInventory.value, supplyId: "supplyID", supplyName: viewModel.supplyName.value, unit: viewModel.supplyUnit.value, lastUpdate: viewModel.updateTime.value)

        FirebaseManager.shared.createSupply(supply: supply)
    }

    func fetchData() {

        FirebaseManager.shared.fetchPets { result in

            switch result {

            case .success(let pets):

                var petsData = [Pet]()
                pets.forEach { pet in
                    petsData.append(pet)
                }
                self.userPetsData = petsData
                print("DidGet:\(self.userPetsData.count)")
            case .failure(let error):
                print("fetchData.failure\(error)")

            }

        }

    }

    @objc func updateSupply() {

        // swiftlint:disable:next line_length
        let supply = Supply(color: viewModel.iconColor.value, cycleTime: viewModel.cycleTime.value, forPets: viewModel.supplyUseByPets.value, fullStock: viewModel.maxInventory.value, iconImage: viewModel.supplyIconImage.value, isReminder: viewModel.isNeedToRemind.value, perCycleTime: viewModel.cycleDosage.value, reminderPercent: viewModel.remindPercentage.value, stock: viewModel.remainingInventory.value, supplyId: viewModel.supplyId.value, supplyName: viewModel.supplyName.value, unit: viewModel.supplyUnit.value, lastUpdate: Timestamp.init(date:Date()))

        FirebaseManager.shared.updateSupply(supplyId: supply.supplyId, data: supply)
    }
    @IBAction func tapButton(_ sender: Any) {

        switch mode {
        case .create:
            createSupply()
        case .edit:
            updateSupply()
        }

        let supply = viewModel.packSupply()

        if viewModel.isNeedToRemind.value {
            NotificationManger.shared.createSupplyNotification(supply: supply)
        } else {
            NotificationManger.shared.deleteNotification(notifyId: "Supply_\(supply.supplyId)")
        }

        self.navigationController?.popViewController(animated: true)
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
                cell.iconImage.image = UIImage(named: icon)
            }

            viewModel.iconColor.bind { color in
                cell.iconImage.backgroundColor = UIColor(named: color)
                cell.stockProgressView.tintColor = UIColor(named: color)
            }

            viewModel.maxInventory.bind { maxStock in
                self.viewModel.remainingInventory.bind { stock in
                    cell.stockLabel.text = "\(maxStock)/\(stock)"
                }
            }

            viewModel.inventoryStatusPercentage.bind { percentage in
                cell.stockProgressView.progress = Float(percentage)
            }

            cell.iconNameCallback = { [weak self] name in

                self?.viewModel.supplyIconImage.value = name

            }

            cell.iconColorCallback = { [weak self] color in
                self?.viewModel.iconColor.value = color
            }

            return cell

        case .name:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyNameTableViewCell.identifier, for: indexPath) as? SupplyNameTableViewCell else { return UITableViewCell() }


            viewModel.supplyName.bind { name in
                cell.textField.text = name
            }

            cell.callback = { [weak self] name in

                self?.viewModel.supplyName.value = name

            }

            return cell

        case .inventory:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyInventoryTableViewCell.identifier, for: indexPath) as? SupplyInventoryTableViewCell else { return UITableViewCell() }

            viewModel.maxInventory.bind { maxStock in
                cell.maxStockTextField.text = "\(maxStock)"
                print("Setting \(maxStock)")
            }

            viewModel.remainingInventory.bind { stock in
                cell.stockTextField.text = "\(stock)"
            }

            viewModel.supplyUnit.bind { unit in
                cell.unitTextField.text = unit
            }

            cell.callbackMaxStock = { [weak self] maxStock in
                self?.viewModel.maxInventory.value = maxStock
                print("over \(maxStock)")
                tableView.reloadData()
            }

            cell.callbackStock = { [weak self] stock in
                self?.viewModel.remainingInventory.value = stock
                tableView.reloadData()
            }

            cell.callbackUnit = { [weak self] unit in
                self?.viewModel.supplyUnit.value = unit
            }

            return cell

        case .pets:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyPetsTableViewCell.identifier, for: indexPath) as? SupplyPetsTableViewCell else { return UITableViewCell() }

            cell.userPetsData = self.userPetsData

            viewModel.supplyUseByPets.bind { pets in
                cell.selectedPets = pets
            }

            cell.callback = { [weak self] pets in
                self?.viewModel.supplyUseByPets.value = pets
            }

            return cell

        case .cycleDosage:

            // swiftlint:disable:next line_length
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyCycleDosageTableViewCell.identifier, for: indexPath) as? SupplyCycleDosageTableViewCell else { return UITableViewCell() }

            viewModel.cycleDosage.bind { number in
                cell.cycleDosageTextfield.text = "\(number)"
            }

            cell.callbackCycleUnit = { [weak self] unit in

                self?.viewModel.cycleTime.value = unit

            }

            cell.callbackCycleDosage = { [weak self] dosage in

                self?.viewModel.cycleDosage.value = dosage

            }

            return cell

        case .reminder:

            // swiftlint:disable:next line_length
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyReminderCellTableViewCell.identifier, for: indexPath) as? SupplyReminderCellTableViewCell else { return UITableViewCell() }

            viewModel.isNeedToRemind.bind { isNeedToRemind in
                cell.switchToggle.isOn = isNeedToRemind
            }

            viewModel.remindPercentage.bind { remindPercentage in
                cell.reminderTextFIeld.text = "\(Int(remindPercentage))"
            }

            cell.callbackToggle = { [weak self] isNeedToRemind in
                self?.viewModel.isNeedToRemind.value = isNeedToRemind
            }

            cell.callbackRemindPercentage = { [weak self] percentage in
                self?.viewModel.remindPercentage.value = percentage
            }

            return cell

        }
    }

}

// MARK: - TableViewDelegate

extension SupplyDetailViewController: UITableViewDelegate {

}
