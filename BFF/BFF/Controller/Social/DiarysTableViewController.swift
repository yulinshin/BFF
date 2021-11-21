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

    @IBOutlet weak var backGroundView: UIView!

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
        viewModel.fetchAllDiary()
        tabBarController?.tabBar.backgroundColor = .white
    }

    func showSetting(with diary: Diary) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        var action = UIAlertAction()

        action = UIAlertAction(title: "封鎖並檢舉此寵物的主人", style: .default, handler: { action in
            self.blockUser(userId: diary.userId)
        })


        // Block PetsId -> Only show on other's Diary
        alertController.addAction(action)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

            self.present(alertController, animated: true, completion: nil)

    }


    func blockUser(userId: String) {

            FirebaseManager.shared.updateCurrentUserBlockUsers(blockUserId: userId)
        FirebaseManager.shared.updateCurrentUserBlockUsers(blockUserId: userId) { result in

            switch result {

            case .success(let message):
                self.viewModel.filterDiaris()
                self.tableView.reloadData()
            case .failure(let error):
                print(error)

            }

        }
    }

}

// MARK: - Table view data source

extension DiariesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryViewCell.identifier, for: indexPath) as? DiaryViewCell else { return UITableViewCell() }

        cell.setup()


            cell.diaryImageView.loadImage( viewModel.showingDiaries.value [indexPath.row].images.first?.url)
            cell.diaryCommentLabel.text = "\(    viewModel.showingDiaries.value [indexPath.row].comments.count)"
            cell.dateLabel.text = "\(   viewModel.showingDiaries.value [indexPath.row].createdTime.dateValue().toString())"
            cell.diaryContentLabel.text = "\(   viewModel.showingDiaries.value [indexPath.row].content)"

            cell.likeLabel.text = "\(   viewModel.showingDiaries.value [indexPath.row].whoLiked.count)"

            if    viewModel.showingDiaries.value [indexPath.row].whoLiked.contains(FirebaseManager.shared.userId) {
                cell.likeIcon.image = UIImage(systemName: "heart.fill")

            } else {
                cell.likeIcon.image = UIImage(systemName: "heart")

            }

        if viewModel.showingDiaries.value[indexPath.row].userId == FirebaseManager.shared.userId {
            cell.settingIcon.isHidden = true
        }else {
            cell.settingIcon.isHidden = false
        }

        if viewModel.showingDiaries.value[indexPath.row].userId == FirebaseManager.shared.userId {
            cell.sendMessageButton.isHidden = true
        }else {
            cell.sendMessageButton.isHidden = false
        }

            cell.petNameLabel.text =    viewModel.showingDiaries.value [indexPath.row].petname
            cell.petImageView.loadImage(   viewModel.showingDiaries.value [indexPath.row].petThumbnail?.url)

            cell.didTapLiked = {
                self.viewModel.updateWhoLiked(index: indexPath.row)
            }

            cell.didTapMoreButton = {
                cell.diaryContentLabel.numberOfLines  = 0
                tableView.reloadData()
            }

            cell.didTapComment = {

                let storyboard = UIStoryboard(name: "Social", bundle: nil)

                guard let controller = storyboard.instantiateViewController(withIdentifier: "CommentTableViewController") as? CommentTableViewController else { return }
                controller.diary =    self.viewModel.showingDiaries.value [indexPath.row]
                self.navigationController?.pushViewController(controller, animated: true)

            }

            cell.didTapSendMessageButton = {
                let storyboard = UIStoryboard(name: "Message", bundle: nil)

                guard let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }

                controller.viewModel = ChatGroupVM( otherUserId: self.viewModel.showingDiaries.value[indexPath.row].userId)

                self.navigationController?.pushViewController(controller, animated: true)


            }



            cell.didTapPetButton = {

                let storyboard = UIStoryboard(name: "Pet", bundle: nil)
                guard let controller = storyboard.instantiateViewController(withIdentifier: "PetsProfileViewController") as? PetsProfileViewController else { return }
                controller.viewModel = ProfileViewModel(petId:    self.viewModel.showingDiaries.value [indexPath.row].petId)

                self.navigationController?.pushViewController(controller, animated: true)


            }

            cell.didTapSettingButton = {
                self.showSetting(with:    self.viewModel.showingDiaries.value [indexPath.row])
            }


            cell.selectionStyle = .none


        return cell

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("*** count: \(viewModel.showingDiaries.value.count)")
        return viewModel.showingDiaries.value.count
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

    @IBOutlet weak var settingIcon: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var diaryContentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    static let identifier = "diariesViewCell"

    var didTapLiked: (() -> Void)?

    var didTapComment: (() -> Void)?

    var didTapMoreButton: (() -> Void)?

    var didTapSendMessageButton: (() -> Void)?

    var didTapPetButton: (() -> Void)?

    var didTapSettingButton: (() -> Void)?


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

        sendMessageButton.isUserInteractionEnabled = true
        sendMessageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapsendMessageButton)))

        petImageView.isUserInteractionEnabled = true
        petImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPetButton)))

        settingIcon.isUserInteractionEnabled = true
        settingIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapSettingButton)))

    }

    @objc func tapsendMessageButton(){

        didTapSendMessageButton?()

    }
    @objc func tapPetButton(){

        didTapPetButton?()

    }



    @objc func tapLikedButton(){

        didTapLiked?()

    }

    @objc func tapCommentButton(){

        didTapComment?()

    }


    @objc func tapSettingButton(){

        didTapSettingButton?()

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
