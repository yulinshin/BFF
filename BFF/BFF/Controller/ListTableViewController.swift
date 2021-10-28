//
//  ListTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/25.
//

import UIKit
import UserNotifications

class ListTableViewController: UITableViewController {


    var viewModel = SuppliesViewMdoel()

    var notificationManert = NotificationManger()



    override func viewDidLoad() {
        super.viewDidLoad()

        let supplyNib = UINib(nibName: "SupplyListTableViewCell", bundle: nil)
        tableView.register(supplyNib, forCellReuseIdentifier: SupplyListTableViewCell.identifier )

        let addCellNib = UINib(nibName: "AddNewItemTableViewCell", bundle: nil)
        tableView.register(addCellNib, forCellReuseIdentifier:    AddNewItemTableViewCell.identifier )
        notificationManert.setUp()

    }

    override func viewWillAppear(_ animated: Bool) {
        
        viewModel.suppiesViewModel.bind { supplyViewModels in
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {

        case 0:

            return viewModel.suppiesViewModel.value.count

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

            viewModel.suppiesViewModel.bind { viewModels in
                print("viewModels = \(viewModels.count)")
                print("indexPath = \(indexPath.row)")
                cell.viewModel = viewModels[indexPath.row]
                cell.configur()

                cell.didTapMoreButtom = {
                    self.showMenu( viewModel: viewModels[indexPath.row] )
                }

                cell.didTapReFillButton = {
                    self.showReFillPopup(viewModel:viewModels[indexPath.row])
                }

            }

            return cell

        default:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewItemTableViewCell.identifier, for: indexPath) as? AddNewItemTableViewCell else { return UITableViewCell() }

            return cell

        }
    }

    func showReFillPopup(viewModel: SupplyViewModel){

        FillSupplyAlertView.shared.showAlert(supplyViewModel: viewModel)

        
    }

    func showMenu(viewModel: SupplyViewModel) {

        let alert = UIAlertController(title: title, message: "要做什麼呢？", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "更新用品資訊", style: .default, handler: { _ in

            self.showNextPage(style: .edit, supplyModel: viewModel)

        }))

        alert.addAction(UIAlertAction(title: "刪除用品", style: .default, handler: { _ in

            viewModel.deleteSuppliesData()

        }))

        if viewModel.isNeedToRemind.value {

            alert.addAction(UIAlertAction(title: "關閉提醒", style: .default, handler: {  _ in

                viewModel.isNeedToRemind.value = false

                self.notificationManert.deleteNotification(notifyId: viewModel.supplyId.value)

            }))

        } else {

            alert.addAction(UIAlertAction(title: "開啟提醒", style: .default, handler: {  _ in

                guard let supply = viewModel.suppply else { return }
                NotificationManger.shared.creatSupplyNotification(supply: supply )
                viewModel.isNeedToRemind.value = true
            }))

        }

        self.present(alert, animated: true, completion: nil)

    }


    func showNextPage(style:SupplyDetailViewController.ConstrolleMode , supplyModel: SupplyViewModel = SupplyViewModel()) {
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
