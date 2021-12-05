//
//  ExploreDiariesViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/4.
//

import UIKit
import FirebaseAuth
import MJRefresh

class ExploreDiariesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var backGroundView: UIView!

    var viewModel = SocialDiaryWallViewModel()
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshAutoNormalFooter()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        viewModel.didUpDateData = { [weak self] in
            self?.tableView.reloadData()
            self?.tableView!.mj_header?.endRefreshing()
            self?.tableView!.mj_footer?.endRefreshing()
        }
        viewModel.noMoreData = { [weak self] in
            self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
        }
        header.setRefreshingTarget(self, refreshingAction: #selector(ExploreDiariesViewController.headerRefresh))
        self.tableView!.mj_header = header
        footer.setRefreshingTarget(self, refreshingAction: #selector(ExploreDiariesViewController.footerRefresh))
        self.tableView!.mj_footer = footer

    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchPublicDiaries()
        tabBarController?.tabBar.backgroundColor = .white
    }

    private func showSetting(with diary: Diary) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        var action = UIAlertAction()

        action = UIAlertAction(title: "封鎖並檢舉此寵物的主人", style: .default, handler: { _ in
            self.blockUser(userId: diary.userId)
        })

        // Block PetsId -> Only show on other's Diary
        alertController.addAction(action)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }

    private func blockUser(userId: String) {
        self.viewModel.blockUser(userId: userId)
    }

}

// MARK: - Table view data source

extension ExploreDiariesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryViewCell.identifier, for: indexPath) as? DiaryViewCell else { return UITableViewCell() }

        cell.setup()

        cell.diaryImageView.loadImage(viewModel.showingDiaries.value[indexPath.row].images.first?.url)

        cell.diaryCommentLabel.text = "\(viewModel.showingDiaries.value[indexPath.row].comments.count)"

        cell.dateLabel.text = "\(viewModel.showingDiaries.value[indexPath.row].createdTime.dateValue().toString())"

        cell.diaryContentLabel.text = "\(viewModel.showingDiaries.value[indexPath.row].content)"

        cell.likeLabel.text = "\(viewModel.showingDiaries.value[indexPath.row].whoLiked.count)"

        if viewModel.showingDiaries.value [indexPath.row].whoLiked.contains(FirebaseManager.userId) {
            cell.likeIcon.image = UIImage(systemName: "heart.fill")

        } else {
            cell.likeIcon.image = UIImage(systemName: "heart")

        }

        if viewModel.showingDiaries.value[indexPath.row].userId == FirebaseManager.userId {
            cell.settingIcon.isHidden = true
            cell.sendMessageButton.isHidden = true
        } else {
            cell.settingIcon.isHidden = false
            cell.sendMessageButton.isHidden = false
        }

        cell.petNameLabel.text = viewModel.showingDiaries.value [indexPath.row].petname
        cell.petImageView.loadImage( viewModel.showingDiaries.value [indexPath.row].petThumbnail?.url)

        cell.didTapLiked = { [weak self] in
            self?.viewModel.updateWhoLiked(index: indexPath.row)
        }

        cell.didTapMoreButton = { [weak self] in
            cell.diaryContentLabel.numberOfLines  = 0
            self?.tableView.reloadData()
        }

        cell.didTapComment = {  [weak self] in
            guard let diary = self?.viewModel.showingDiaries.value[indexPath.row] else { return }
            self?.showComment(diary: diary)
        }

        cell.didTapSendMessageButton = { [weak self] in

            guard let otherUserId = self?.viewModel.showingDiaries.value[indexPath.row].userId else { return }
            self?.showChatVC(userId: otherUserId)

        }

        cell.didTapPetButton = { [weak self] in

            guard let petId = self?.viewModel.showingDiaries.value[indexPath.row].petId else { return }
            self?.showPetProfile(petId: petId)

        }

        cell.didTapSettingButton = { [weak self] in
            guard let viewModel = self?.viewModel else { return }
            self?.showSetting(with: viewModel.showingDiaries.value[indexPath.row])
        }

        cell.selectionStyle = .none

        return cell
    }

    private func showPetProfile(petId: String) {
        let storyboard = UIStoryboard(name: "Pet", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "PetsProfileViewController") as? PetsProfileViewController else { return }
        controller.viewModel = ProfileViewModel(petId: petId)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    private func showChatVC(userId: String) {

        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        controller.viewModel = ChatGroupVM( otherUserId: userId)
        self.navigationController?.pushViewController(controller, animated: true)

    }

    private func showComment(diary: Diary) {

        let storyboard = UIStoryboard(name: "Social", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "CommentTableViewController") as? CommentTableViewController else { return }
        controller.diary = diary
        self.navigationController?.pushViewController(controller, animated: true)

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
    }

}

extension ExploreDiariesViewController {
    @objc func headerRefresh() {
        viewModel.fetchPublicDiaries()
    }
    @objc func footerRefresh() {
        viewModel.fetchPublicDiaries(isFetchMore: true)
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

    @objc func tapsendMessageButton() {

        didTapSendMessageButton?()

    }

    @objc func tapPetButton() {

        didTapPetButton?()

    }

    @objc func tapLikedButton() {

        didTapLiked?()
    }

    @objc func tapCommentButton() {
        didTapComment?()
    }

    @objc func tapSettingButton() {

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