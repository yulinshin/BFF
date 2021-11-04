//
//  DiarysTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/4.
//

import UIKit
import FirebaseAuth

class DiarysViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel = DiaryWallViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        viewModel.didupDateData = {
            self.tableView.reloadData()
        }

    }


    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchDiary()
    }
}

// MARK: - Table view data source

extension DiarysViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryViewCell.identifier, for: indexPath) as? DiaryViewCell else { return UITableViewCell() }

        cell.setup()

        viewModel.showingDiarys.bind { diarys in

            cell.diaryImageVIew.loadImage(diarys[indexPath.row].images.first?.url)
            cell.diaryCommentLabel.text = "\( diarys[indexPath.row].comments.count)"
            cell.dateLabel.text = "\(diarys[indexPath.row].createdTime.dateValue().toString())"
            cell.diaryContentLabel.text = "\(diarys[indexPath.row].content)"

            cell.llkeLabel.text = "\(diarys[indexPath.row].whoLiked.count)"

            if diarys[indexPath.row].whoLiked.contains(FirebaseManager.shared.userId) {
                cell.likeicon.image = UIImage(systemName: "heart.fill")

            } else {
                cell.likeicon.image = UIImage(systemName: "heart")

            }

            cell.didTapLiked = {
                self.viewModel.updateWhoLiked(index: indexPath.row)
            }

            FirebaseManager.shared.fetchPet(petId: diarys[indexPath.row].petId) { result in

                switch result {

                case.success(let pet):

                        guard let data = pet.petThumbnail?.url else { return }
                        print("setImageFor\(indexPath.row) : \(pet.name)")
                        cell.petImageVIew.loadImage(data)
                        cell.petNameLabel.text = pet.name


                case.failure(let error):

                        print(error)

                }
            }

            cell.selectionStyle = .none

        }

        return cell

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.diarys.value.count
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Diary", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        controller.viewModel = DetialViewModel(from: viewModel.diarys.value[indexPath.row])
        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")
        self.navigationController?.show(controller, sender: nil)



    }

}

class DiaryViewCell: UITableViewCell {

    @IBOutlet weak var diaryImageVIew: UIImageView!

    @IBOutlet weak var photoBackgroundVIew: UIView!
    @IBOutlet weak var diaryCommentLabel: UILabel!
    @IBOutlet weak var petImageVIew: UIImageView!
    @IBOutlet weak var commentIcon: UIImageView!

    @IBOutlet weak var llkeLabel: UILabel!
    @IBOutlet weak var likeicon: UIImageView!
    @IBOutlet weak var diaryContentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!

    static let identifier = "DiarysViewCell"

    var didTapLiked: (()->Void)?

    var didTapComment: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }


    func setup() {

        photoBackgroundVIew.backgroundColor = .white
        photoBackgroundVIew.layer.cornerRadius = 10
        diaryImageVIew.layer.cornerRadius = 20
        diaryImageVIew.clipsToBounds = true
        diaryImageVIew.contentMode = .scaleAspectFill
        photoBackgroundVIew.layer.shadowColor = UIColor.gray.cgColor
        photoBackgroundVIew.layer.shadowOpacity = 0.2
        photoBackgroundVIew.layer.shadowRadius = 4
        photoBackgroundVIew.layer.shadowOffset = CGSize(width: 1, height: 1)
        petImageVIew.layer.cornerRadius = 20

        likeicon.isUserInteractionEnabled = true
        likeicon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLikedButton)))

        likeicon.isUserInteractionEnabled = true
        commentIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCommentButton)))
    }

    @objc func tapLikedButton(){

        didTapLiked?()

    }

    @objc func tapCommentButton(){

        didTapComment?()

    }



}
