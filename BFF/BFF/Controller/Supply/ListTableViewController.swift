//
//  ListTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import UIKit
import UserNotifications

class ListTableViewController: UITableViewController {


    var viewModel = SuppliesViewModel()

    var notificationManger = NotificationManger()



    override func viewDidLoad() {
        super.viewDidLoad()

        let supplyNib = UINib(nibName: "SupplyListTableViewCell", bundle: nil)
        tableView.register(supplyNib, forCellReuseIdentifier: SupplyListTableViewCell.identifier )

        let addCellNib = UINib(nibName: "AddNewItemTableViewCell", bundle: nil)
        tableView.register(addCellNib, forCellReuseIdentifier:    AddNewItemTableViewCell.identifier )
        notificationManger.setUp()

        viewModel.suppliesDidChange = {
            self.tableView.reloadData()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchSuppliesData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {

        case 0:

            return viewModel.suppliesViewModel.value.count

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


                let cellViewModel = viewModel.suppliesViewModel.value[indexPath.row]
                cell.viewModel = cellViewModel
                cell.configure()
                cell.didTapMoreButton = {
                    self.showMenu( viewModel: cellViewModel )
                }

                cell.didTapReFillButton = {
                    self.showReFillPopup(viewModel: cellViewModel )
                }
            cell.selectedBackgroundView?.backgroundColor = .white

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewItemTableViewCell.identifier, for: indexPath) as? AddNewItemTableViewCell else { return UITableViewCell() }
            cell.selectedBackgroundView?.backgroundColor = .white
            return cell

        }
    }

    func showReFillPopup(viewModel: SupplyViewModel){

        FillSupplyAlertView.shared.showAlert(supplyViewModel: viewModel)

        
    }

    func showMenu(viewModel: SupplyViewModel) {

        let alert = UIAlertController(title: viewModel.supplyName.value, message: "要做什麼呢？", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "更新用品資訊", style: .default, handler: { _ in

            self.showNextPage(style: .edit, supplyModel: viewModel)

        }))

        alert.addAction(UIAlertAction(title: "刪除用品", style: .default, handler: { _ in

            viewModel.deleteSuppliesData()
            self.viewModel.fetchSuppliesData()

        }))

        if viewModel.isNeedToRemind.value {

            alert.addAction(UIAlertAction(title: "關閉提醒", style: .default, handler: {  _ in

                viewModel.isNeedToRemind.value = false
                viewModel.updateToDataBase()
                self.notificationManger.deleteNotification(notifyId: viewModel.supplyId.value)

            }))

        } else {

            alert.addAction(UIAlertAction(title: "開啟提醒", style: .default, handler: {  _ in

                guard let supply = viewModel.supply else { return }
                NotificationManger.shared.createSupplyNotification(supply: supply )
                viewModel.isNeedToRemind.value = true
                viewModel.updateToDataBase()
            }))

        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {  _ in

        }))

        self.present(alert, animated: true, completion: nil)

    }


    func showNextPage(style: SupplyDetailViewController.ControllerMode, supplyModel: SupplyViewModel = SupplyViewModel()) {
        let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SupplyDetailViewController") as? SupplyDetailViewController else { return }

        controller.viewModel = supplyModel
        controller.mode = .edit

            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Supplies", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "SupplyDetailViewController") as? SupplyDetailViewController else { return }

        switch indexPath.section {

        case 1:

            controller.mode = .create
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)

        default:
            return
        }

    }
    
}
