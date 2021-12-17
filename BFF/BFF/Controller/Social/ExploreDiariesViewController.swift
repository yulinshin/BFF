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

    private var viewModel = SocialDiaryWallViewModel()
    private let header = MJRefreshNormalHeader()
    private let footer = MJRefreshAutoNormalFooter()

// MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        setupViewModel()
        setupHeaderFooter()

    }

    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.backgroundColor = .white
    }

    deinit {
        print("#### ExploreDiariesViewController deinit")
    }

    private func setupHeaderFooter() {

        header.setRefreshingTarget(self, refreshingAction: #selector(ExploreDiariesViewController.headerRefresh))
        self.tableView!.mj_header = header

        footer.setRefreshingTarget(self, refreshingAction: #selector(ExploreDiariesViewController.footerRefresh))
        self.tableView!.mj_footer = footer

    }

    private func setupViewModel() {

        viewModel.didUpDateData = { [weak self] in
            self?.tableView.reloadData()
            self?.tableView!.mj_header?.endRefreshing()
            self?.tableView!.mj_footer?.endRefreshing()
        }

        viewModel.noMoreData = { [weak self] in
            self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
        }

        viewModel.fetchPublicDiaries()
    }
}

// MARK: - Table view data source

extension ExploreDiariesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showingDiaries.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DiaryViewCell.identifier, for: indexPath) as? DiaryViewCell else { return UITableViewCell() }

        do {
            try checkIndexPathRange(dataRange: viewModel.showingDiaries.value.count, indexPath: indexPath)

            cell.setup()
            cell.delegate = self
            cell.indexPath = indexPath.row
            cell.selectionStyle = .none

            viewModel.showingDiaries.bind { cellViewModels in
                let viewModels =  cellViewModels[indexPath.row]
                cell.filledData(viewModel: viewModels)
            }

        } catch {

            return UITableViewCell()

        }

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
}

// MARK: - UserInteractive

extension ExploreDiariesViewController {
    @objc func headerRefresh() {
        viewModel.fetchPublicDiaries()
    }
    @objc func footerRefresh() {
        viewModel.fetchPublicDiaries(isFetchMore: true)
    }
}

extension ExploreDiariesViewController: SocialDiaryCellDelegate {

    func didTapLiked(cell: DiaryViewCell, indexPath: Int) {
        self.viewModel.updateWhoLiked(index: indexPath)
    }

    func didTapMoreButton(cell: DiaryViewCell, indexPath: Int) {
        cell.diaryContentLabel.numberOfLines  = 0
        self.tableView.reloadData()
    }

    func didTapComment(cell: DiaryViewCell, indexPath: Int) {
        self.showComment(diary: viewModel.showingDiaries.value[indexPath].diary.value, indexPath: indexPath)
    }

    func didTapSendMessageButton(cell: DiaryViewCell, indexPath: Int) {
        self.showChatVC(userId: viewModel.showingDiaries.value[indexPath].diary.value.userId)
    }

    func didTapPetButton(cell: DiaryViewCell, indexPath: Int) {
        self.showPetProfile(petId: viewModel.showingDiaries.value[indexPath].diary.value.petId)
    }

    func didTapSettingButton(cell: DiaryViewCell, indexPath: Int) {
        self.showSetting(with: viewModel.showingDiaries.value[indexPath].diary.value)
    }

    private func showSetting(with diary: Diary) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        var action = UIAlertAction()

        action = UIAlertAction(title: "封鎖並檢舉此寵物的主人", style: .default, handler: { _ in
            self.blockUser(userId: diary.userId)
        })

        alertController.addAction(action)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

        self.present(alertController, animated: true, completion: nil)

    }

    private func blockUser(userId: String) {
        self.viewModel.blockUser(userId: userId)
    }

}
