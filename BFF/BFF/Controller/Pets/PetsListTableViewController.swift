//
//  PetsListTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/31.
//

import UIKit

class PetsListTableViewController: UITableViewController {


    var viewModels = [CreatPetViewModel]() {
        didSet{
            tableView.reloadData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

    }


    override func viewWillAppear(_ animated: Bool) {
        getPetData()
    }


    func getPetData(){
        FirebaseManager.shared.fetchUserPets { result in


            switch result {

            case.success(let pets):

                self.viewModels.removeAll()
                pets.forEach { pet in
                    let petModel = CreatPetViewModel(from: pet)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PetHealthCardListTableViewCell.indentfier, for: indexPath) as? PetHealthCardListTableViewCell else { return UITableViewCell()}



        cell.configur()
        
        cell.selectedBackgroundView?.backgroundColor = .white

        viewModels[indexPath.row].petThumbnail.bind { url in
            cell.petImage.loadImage(url)
        }

        viewModels[indexPath.row].name.bind { name in
            cell.nameLabel.text = name
        }

        viewModels[indexPath.row].birthday.bind { birthady in
            cell.bitrhdayLabel.text = birthady
        }

        cell.didTapdeleteButton = {
            self.viewModels[indexPath.row].deleatePet()
            self.viewModels.remove(at: indexPath.row)
            tableView.reloadData()
        }

        cell.didTapMoreInfoButton = {

            let storyboard = UIStoryboard(name: "Pet", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "CreatPetViewController") as? CreatPetViewController else { return }
            controller.presentMode = .read
            controller.viewModel = self.viewModels[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)

        }

        return cell
    }

}
