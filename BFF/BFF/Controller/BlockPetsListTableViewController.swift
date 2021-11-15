//
//  BlockPetsListTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/12.
//

import UIKit

class BlockPetsListTableViewController: UITableViewController {


    var viewModel = BlocksViewModelList(userId: FirebaseManager.shared.userId)

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.didUpdateData = {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.blocks.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTableViewCell", for: indexPath) as? BlockTableViewCell else { return UITableViewCell() }

        cell.setup(viewModel: viewModel.blocks.value[indexPath.row])

        cell.didTapBlockButton = {
            self.viewModel.ubBlock(indexPath: indexPath.row)
        }


        return cell
    }
}


class BlockTableViewCell: UITableViewCell {

    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UILabel!
    var didTapBlockButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

    }

    func setup (viewModel: BlocksViewModel) {
        petImage.loadImage(viewModel.image.value)
        petName.text = viewModel.name.value
    }

    @IBAction func tapUnBlockButton(_ sender: Any) {

        self.didTapBlockButton?()

    }


}
