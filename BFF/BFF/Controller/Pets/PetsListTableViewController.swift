//
//  PetsListTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/31.
//

import UIKit

class PetsListTableViewController: UITableViewController {

    var viewModels = [CreatePetViewModel]() {
        didSet {

            tableView.reloadData()

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        getPetData()
    }

    func getPetData() {
        FirebaseManager.shared.fetchUserPets { result in

            switch result {

            case.success(let pets):

                self.viewModels.removeAll()
                pets.forEach { pet in
                    let petModel = CreatePetViewModel(from: pet)
                    self.viewModels.append(petModel)
                }

            case.failure(let error):

                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetHealthCardListTableViewCell.identifier, for: indexPath) as? PetHealthCardListTableViewCell else { return UITableViewCell()}

        cell.configure()
        
        cell.selectedBackgroundView?.backgroundColor = .white

        viewModels[indexPath.row].petThumbnail.bind { url in
            cell.petImage.loadImage(url)
        }

        viewModels[indexPath.row].name.bind { name in
            cell.nameLabel.text = name
        }

        viewModels[indexPath.row].birthday.bind { birthday in
            cell.birthdayLabel.text = birthday
        }

        cell.didTapDeleteButton = {

            let alertController = UIAlertController(title: "刪除寵物", message: "此為不可逆的動作，你確定要刪除寵物嗎？", preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: "刪除", style: .default) { _ in
                self.viewModels[indexPath.row].deletePet()
                self.viewModels.remove(at: indexPath.row)
                tableView.reloadData()
            }

            alertController.addAction(deleteAction)

            alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

                self.present(alertController, animated: true, completion: nil)

        }

        cell.didTapMoreInfoButton = {

            let storyboard = UIStoryboard(name: "Pet", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatePetViewController") as? CreatePetViewController else { return }
            controller.presentMode = .read
            controller.viewModel = self.viewModels[indexPath.row]

            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)

        }

        return cell
    }

}
