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

    static var identifier = "ListTableViewController"

    override func viewDidLoad() {
        super.viewDidLoad()

        let supplyNib = UINib(nibName: SupplyListTableViewCell.identifier, bundle: nil)
        tableView.register(supplyNib, forCellReuseIdentifier: SupplyListTableViewCell.identifier)

        let addCellNib = UINib(nibName: AddNewItemTableViewCell.identifier, bundle: nil)
        tableView.register(addCellNib, forCellReuseIdentifier: AddNewItemTableViewCell.identifier)

        notificationManger.setUp()

        viewModel.suppliesDidChange = { [weak self] in
            self?.tableView.reloadData()
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

            return viewModel.suppliesViewModel.value.count // Showing Supply Cell

        case 1: // For add Supply Cell

            return  1

        default:
            return  0

        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0: // Showing Supply Cell

            guard let cell = tableView.dequeueReusableCell(withIdentifier: SupplyListTableViewCell.identifier, for: indexPath) as? SupplyListTableViewCell else { return UITableViewCell() }

            cell.viewModel = viewModel.suppliesViewModel.value[indexPath.row]
            cell.configure()
            cell.didTapMoreButton = { [weak self] in
                guard let cellViewModel = self?.viewModel.suppliesViewModel.value[indexPath.row] else { return }
                self?.showMenu(viewModel: cellViewModel)
            }

            cell.didTapReFillButton = { [weak self] in
                guard let cellViewModel = self?.viewModel.suppliesViewModel.value[indexPath.row] else { return }
                self?.showReFillPopup(viewModel: cellViewModel)
            }

            cell.selectedBackgroundView?.backgroundColor = .white

            return cell

        default:  // For add Supply Cell

            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddNewItemTableViewCell.identifier, for: indexPath) as? AddNewItemTableViewCell else { return UITableViewCell() }
            cell.selectedBackgroundView?.backgroundColor = .white
            return cell

        }
    }

    private func showReFillPopup(viewModel: SupplyViewModel) {

        FillSupplyAlertView.shared.showAlert(supplyViewModel: viewModel)

    }

    private func showMenu(viewModel: SupplyViewModel) {

        let alert = UIAlertController(title: viewModel.supplyName.value, message: "??????????????????", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "??????????????????", style: .default, handler: { _ in

            self.showNextPage(style: .edit, supplyModel: viewModel)

        }))

        alert.addAction(UIAlertAction(title: "????????????", style: .default, handler: { _ in

            viewModel.deleteSuppliesData()
            self.viewModel.fetchSuppliesData()

        }))

        if viewModel.isNeedToRemind.value {

            alert.addAction(UIAlertAction(title: "????????????", style: .default, handler: {  _ in

                viewModel.isNeedToRemind.value = false
                viewModel.updateToDataBase()
                self.notificationManger.deleteNotification(notifyId: viewModel.supplyId.value)

            }))

        } else {

            alert.addAction(UIAlertAction(title: "????????????", style: .default, handler: {  _ in

                guard let supply = viewModel.supply else { return }
                NotificationManger.shared.createSupplyNotification(supply: supply )
                viewModel.isNeedToRemind.value = true
                viewModel.updateToDataBase()
            }))

        }

        alert.addAction(UIAlertAction(title: "??????", style: .cancel, handler: {  _ in

        }))

        self.present(alert, animated: true, completion: nil)

    }

    private func showNextPage(style: SupplyDetailViewController.ControllerMode, supplyModel: SupplyViewModel = SupplyViewModel()) {
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
