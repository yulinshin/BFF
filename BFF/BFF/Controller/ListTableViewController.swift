//
//  ListTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import UIKit

class ListTableViewController: UITableViewController {


    var viewModel = SuppliesViewMdoel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let supplyNib = UINib(nibName: "SupplyListTableViewCell", bundle: nil)
        tableView.register(supplyNib, forCellReuseIdentifier: SupplyListTableViewCell.identifier )

        let addCellNib = UINib(nibName: "AddNewItemTableViewCell", bundle: nil)
        tableView.register(addCellNib, forCellReuseIdentifier:    AddNewItemTableViewCell.identifier )


        viewModel.suppiesViewModel.bind { supplyViewModels in
            self.tableView.reloadData()
        }

    }

    override func viewWillAppear(_ animated: Bool) {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {

        case 0:

            return  viewModel.suppiesViewModel.value.count

        case 1:
            return  1
        default:
            return  0

        }

    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyListTableViewCell.identifier, for: indexPath) as? SupplyListTableViewCell else { return UITableViewCell() }

            cell.viewModel = viewModel.suppiesViewModel.value[indexPath.row]
            cell.configur()

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewItemTableViewCell.identifier, for: indexPath) as? AddNewItemTableViewCell else { return UITableViewCell() }

            return cell

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SupplyDetailViewController") as? SupplyDetailViewController else { return }

        switch indexPath.section {

        case 0:

            let supplyModel = viewModel.suppiesViewModel.value[indexPath.row]
            
            // swiftlint:disable:next line_length
            let supply = Supply(color: supplyModel.iconColor.value, cycleTime: supplyModel.cycleTime.value, forPets: supplyModel.supplyUseByPets.value, fullStock: supplyModel.maxInventory.value, iconImage: supplyModel.supplyIconImage.value, isReminder: supplyModel.isNeedToRemind.value, perCycleTime: supplyModel.cycleDosage.value, reminderPercent: supplyModel.remindPercentage.value, stock: supplyModel.reminingInventory.value, supplyId: "supplyID", supplyName: supplyModel.supplyName.value, unit: supplyModel.suppluUnit.value)

            controller.viewModel = SupplyViewModel(from: supply)
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)


        default:

            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)

          
        }



    }

}
