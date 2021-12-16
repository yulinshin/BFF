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
        viewModel.fetchPublicDiaries()

    }

    override func viewWillAppear(_ animated: Bool) {
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

        viewModel.showingDiaries.bind { cellViewModels in
            let viewModels =  cellViewModels[indexPath.row]
            cell.filledData(viewModel: viewModels)

        cell.didTapLiked = { [weak self] in
            self?.viewModel.updateWhoLiked(index: indexPath.row)
        }

        cell.didTapMoreButton = { [weak self] in
            cell.diaryContentLabel.numberOfLines  = 0
            self?.tableView.reloadData()
        }

        cell.didTapComment = {  [weak self] in

            self?.showComment(diary: viewModels.diary.value, indexPath: indexPath.row)
        }

        cell.didTapSendMessageButton = { [weak self]  in

            self?.showChatVC(userId: viewModels.diary.value.userId)

        }

        cell.didTapPetButton = { [weak self]  in

            self?.showPetProfile(petId: viewModels.diary.value.petId)

        }

        cell.didTapSettingButton = { [weak self]  in
            self?.showSetting(with: viewModels.diary.value)
        }
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

    private func showComment(diary: Diary, indexPath: Int) {

        if let detailController = self.storyboard?.instantiateViewController(identifier: "CommentTableViewController", creator: { coder in
            CommentTableViewController(coder: coder, diary: diary)
        }) {
            detailController.callBack = { [weak self] comments in
                self?.viewModel.showingDiaries.value[indexPath].diary.value.comments = comments.map({$0.petId})
            }
            self.navigationController?.show(detailController, sender: nil)
        } 
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

    func filledData(viewModel: SocialDiaryCellViewModel) {

        viewModel.diary.bind { diary in
            self.diaryCommentLabel.text = "\(diary.comments.count)"
            self.diaryImageView.loadImage( diary.images.first?.url)

            self.dateLabel.text = "\(diary.createdTime.dateValue().toString())"

            self.diaryContentLabel.text = "\(diary.content)"

            self.likeLabel.text = "\(diary.whoLiked.count)"

            if diary.whoLiked.contains(FirebaseManager.shared.userId) {
                self.likeIcon.image = UIImage(systemName: "heart.fill")

            } else {
                self.likeIcon.image = UIImage(systemName: "heart")

            }

            if  diary.userId == FirebaseManager.shared.userId {
                self.settingIcon.isHidden = true
                self.sendMessageButton.isHidden = true
            } else {
                self.settingIcon.isHidden = false
                self.sendMessageButton.isHidden = false
            }

            self.petNameLabel.text = diary.petName
            self.petImageView.loadImage( diary.petThumbnail?.url)

        }

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
