//
//  diariesTableViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/4.
//

import UIKit
import FirebaseAuth

class DiariesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel = DiaryWallViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        viewModel.didUpDateData = {
            self.tableView.reloadData()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchDiary()
    }
}

// MARK: - Table view data source

extension DiariesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryViewCell.identifier, for: indexPath) as? DiaryViewCell else { return UITableViewCell() }

        cell.setup()

        viewModel.showingDiaries.bind { diaries in

            cell.diaryImageView.loadImage(diaries[indexPath.row].images.first?.url)
            cell.diaryCommentLabel.text = "\( diaries[indexPath.row].comments.count)"
            cell.dateLabel.text = "\(diaries[indexPath.row].createdTime.dateValue().toString())"
            cell.diaryContentLabel.text = "\(diaries[indexPath.row].content)"

            cell.likeLabel.text = "\(diaries[indexPath.row].whoLiked.count)"

            if diaries[indexPath.row].whoLiked.contains(FirebaseManager.shared.userId) {
                cell.likeIcon.image = UIImage(systemName: "heart.fill")

            } else {
                cell.likeIcon.image = UIImage(systemName: "heart")

            }

            cell.petNameLabel.text = diaries[indexPath.row].petname
            cell.petImageView.loadImage(diaries[indexPath.row].petThumbnail?.url)

            cell.didTapLiked = {
                self.viewModel.updateWhoLiked(index: indexPath.row)
            }

            cell.didTapMoreButton = {
                cell.diaryContentLabel.numberOfLines  = 0
                tableView.reloadData()
            }

            cell.didTapComment = {

                let storyboard = UIStoryboard(name: "Soical", bundle: nil)

                guard let controller = storyboard.instantiateViewController(withIdentifier: "CommentTableViewController") as? CommentTableViewController else { return }
                controller.diary = diaries[indexPath.row]
                self.navigationController?.pushViewController(controller, animated: true)

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
        return viewModel.diaries.value.count
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        let storyboard = UIStoryboard(name: "Diary", bundle: nil)
//        guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
//        controller.viewModel = DetialViewModel(from: viewModel.diaries.value[indexPath.row])
//        self.navigationController?.navigationBar.tintColor = UIColor(named: "main")
//        self.navigationController?.show(controller, sender: nil)



    }

}

class DiaryViewCell: UITableViewCell {

    @IBOutlet weak var diaryImageView: UIImageView!

    @IBOutlet weak var photoBackgroundView: UIView!
    @IBOutlet weak var diaryCommentLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var commentIcon: UIImageView!

    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var diaryContentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!

    @IBOutlet weak var moreButton: UIButton!
    static let identifier = "diariesViewCell"

    var didTapLiked: (() -> Void)?

    var didTapComment: (() -> Void)?

    var didTapMoreButton: (() -> Void)?

    var isNeedToOpen = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }


    func setup() {

        photoBackgroundView.backgroundColor = .white
        photoBackgroundView.layer.cornerRadius = 10
        diaryImageView.layer.cornerRadius = 20
        diaryImageView.clipsToBounds = true
        diaryImageView.contentMode = .scaleAspectFill
        photoBackgroundView.layer.shadowColor = UIColor.gray.cgColor
        photoBackgroundView.layer.shadowOpacity = 0.2
        photoBackgroundView.layer.shadowRadius = 4
        photoBackgroundView.layer.shadowOffset = CGSize(width: 1, height: 1)
        petImageView.layer.cornerRadius = 20

        likeIcon.isUserInteractionEnabled = true
        likeIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLikedButton)))

        commentIcon.isUserInteractionEnabled = true
        commentIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCommentButton)))

    }

    @objc func tapLikedButton(){

        didTapLiked?()

    }

    @objc func tapCommentButton(){

        didTapComment?()

    }

    @IBAction func showMore(_ sender: UIButton) {

        didTapMoreButton?()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if diaryContentLabel.isTruncated() {
            moreButton.isHidden = false
        } else { 
            moreButton.isHidden = true
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
