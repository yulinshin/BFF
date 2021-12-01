//
//  PetsProfileViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/8.
//

import UIKit
import SwiftUI
import Kingfisher

class PetsProfileViewController: UIViewController {

    @IBOutlet weak var petThumbnailImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var ageLabel: UILabel!

    @IBOutlet weak var birthdayLabel: UILabel!

    @IBOutlet weak var diariesCountLabel: UILabel!

    @IBOutlet weak var followersCountLabel: UILabel!

    @IBOutlet weak var likedCountLabel: UILabel!

    @IBOutlet weak var followButton: UIButton!

    @IBOutlet weak var sendMessageButton: UIButton!

    @IBOutlet weak var moreButtonImageVIew: UIImageView!

    @IBOutlet weak var diariesCollectionView: UICollectionView!

    @IBOutlet weak var topColorBackground: UIView!
    @IBOutlet weak var petScrollView: UIScrollView!

    @IBOutlet weak var actionStackView: UIStackView!
    var viewModel: ProfileViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        diariesCollectionView.collectionViewLayout = createLayout()
        diariesCollectionView.delegate = self
        diariesCollectionView.dataSource = self
        let diaryNib = UINib(nibName: "DairyPhotoCell", bundle: nil)
        diariesCollectionView.register(diaryNib, forCellWithReuseIdentifier: DairyPhotoCell.identifier)
        petScrollView.delegate = self
        viewModel?.gotData = { [weak self] in
            self?.diariesCollectionView.reloadData()
            self?.setUp()
        }

        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white

        moreButtonImageVIew.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMoreButton)))
        moreButtonImageVIew.isUserInteractionEnabled = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    // swiftlint:disable:next function_body_length
    func createLayout() -> UICollectionViewLayout {

            let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in

                let tripletSquareItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1/3),
                        heightDimension: .fractionalWidth(1/3)
                    )
                )
                tripletSquareItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                let tripletSquareItemVertical = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )
                tripletSquareItemVertical.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                let largeSquareItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(2/3),
                        heightDimension: .fractionalWidth(2/3)
                    )
                )
                largeSquareItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(1/3)
                    ),
                    subitem: tripletSquareItem,
                    count: 3
                )

                let verticalGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1/3),
                        heightDimension: .fractionalWidth(2/3)
                    ),
                    subitem: tripletSquareItemVertical,
                    count: 2
                )

                let horizontalComboOneGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(2/3)
                    ),
                    subitems: [
                        largeSquareItem,
                        verticalGroup
                    ]
                )

                let horizontalComboTwoGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(2/3)
                    ),
                    subitems: [
                        verticalGroup,
                        largeSquareItem
                    ]
                )

                let finalGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(2.0)
                    ),
                    subitems: [
                        horizontalComboOneGroup,
                        threeItemGroup,
                        horizontalComboTwoGroup,
                        threeItemGroup
                    ]
                )
                return NSCollectionLayoutSection(group: finalGroup)
            }

        return layout

    }

    private func setupMessageButton() {
        self.sendMessageButton.backgroundColor = .white
        self.sendMessageButton.layer.borderColor = UIColor.mainColor.cgColor
        self.sendMessageButton.layer.borderWidth = 1
        self.sendMessageButton.layer.cornerRadius = 8
        self.sendMessageButton.setTitle("私訊主人", for: .normal)
    }

    fileprivate func setupPetThumbnail() {
        self.petThumbnailImageView.layer.cornerRadius = self.petThumbnailImageView.frame.height/2
        self.petThumbnailImageView.layer.borderColor = UIColor.white.cgColor
        self.petThumbnailImageView.layer.borderWidth = 4
    }

    func setUp() {

        guard let viewModel = viewModel else {
            return
        }

        if viewModel.ownerUserId.value == FirebaseManager.userId {
            actionStackView.isHidden = true
        } else {
            actionStackView.isHidden = false
        }

        viewModel.petImageThumbnailUrl.bind { url in
            self.petThumbnailImageView.loadImage(url, placeHolder: UIImage(named: "PetThumbnailPlaceHolder"))
        }
        viewModel.petName.bind { name in
            self.nameLabel.text = name
        }

        viewModel.age.bind { age in
            self.ageLabel.text = age
        }

        viewModel.birthDay.bind { birthday in
            self.birthdayLabel.text = birthday
        }

        viewModel.followersCount.bind { followersCount in
            self.followersCountLabel.text = "\(followersCount)"
        }

        viewModel.diariesCount.bind { diariesCount in
            self.diariesCountLabel.text = "\(diariesCount)"
        }

        viewModel.likedCount.bind { likedCount in
            self.likedCountLabel.text = "\(likedCount)"
        }

        viewModel.isFollowed.bind { isFollowed in

            if isFollowed {
                self.followButton.backgroundColor = .white
                self.followButton.layer.borderColor = UIColor.mainColor.cgColor
                self.followButton.layer.borderWidth = 1
                self.followButton.setTitle("已追蹤", for: .normal)
                self.followButton.setTitleColor(UIColor.mainColor, for: .normal)
                self.followButton.layer.cornerRadius = 8
            } else {

                self.followButton.backgroundColor = UIColor.mainColor
                self.followButton.layer.borderColor = UIColor.mainColor.cgColor
                self.followButton.layer.borderWidth = 1
                self.followButton.setTitle("追蹤", for: .normal)
                self.followButton.setTitleColor(.white, for: .normal)
                self.followButton.layer.cornerRadius = 8
            }

        }

        setupMessageButton()
        setupPetThumbnail()
        self.topColorBackground.layer.cornerRadius = self.topColorBackground.frame.width / 2

    }

    @IBAction func didTapFollowButton(_ sender: UIButton) {

        guard let viewModel = viewModel else {
            return
        }

            if viewModel.isFollowed.value {

                FirebaseManager.shared.removePetFollower(petId: viewModel.petId.value)

                viewModel.followersCount.value -= 1
                viewModel.isFollowed.value = false

            } else {

                FirebaseManager.shared.updatePetFollower(petId: viewModel.petId.value)

                viewModel.followersCount.value += 1
                viewModel.isFollowed.value = true

            }

    }

    @IBAction func didTapSendMessageButton(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Message", bundle: nil)

        guard let controller = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }

        guard let viewModel = viewModel else {
            return
        }

        controller.viewModel = ChatGroupVM( otherUserId: viewModel.ownerUserId.value)

        self.navigationController?.show(controller, sender: nil)

    }

    @objc func didTapMoreButton() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        guard let viewModel = viewModel else {
            return
        }

        var action = UIAlertAction()

            if viewModel.isBlocked.value {

                action = UIAlertAction(title: "解除封鎖此寵物的主人", style: .default, handler: blockUser)

            } else {

            action = UIAlertAction(title: "封鎖並檢舉此寵物的主人", style: .default, handler: blockUser)
            }

        // Block PetsId -> Only show on other's Diary
        alertController.addAction(action)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))

            self.present(alertController, animated: true, completion: nil)

    }

    func blockUser(_ action: UIAlertAction) {

        guard let viewModel = viewModel else {
            return
        }

            if viewModel.isBlocked.value {

                FirebaseManager.shared.unblockUser(blockUserId: viewModel.ownerUserId.value)

                viewModel.isBlocked.value = false

            } else {

                FirebaseManager.shared.updateBlockUser(blockUserId: viewModel.ownerUserId.value)

                viewModel.isBlocked.value = true

            }
    }

}

extension PetsProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return viewModel?.diaries.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DairyPhotoCell.identifier, for: indexPath) as? DairyPhotoCell else { return UICollectionViewCell() }

        viewModel?.diaries.bind(listener: { diaries in

            cell.image.loadImage(diaries[indexPath.row].images.first?.url, placeHolder: UIImage(named: "DiaryPlaceHolder"))

        })
        return cell
    }

}

extension PetsProfileViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let diary = viewModel?.diaries.value[indexPath.row] else { return }
        let storyboard = UIStoryboard(name: "Diary", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        controller.viewModel = DetailViewModel(from: diary)
        self.navigationController?.show(controller, sender: nil)

    }
}

class ProfileViewModel {

    let petId = Box("")
    let petImageThumbnailUrl = Box("")
    let petName = Box("")
    let birthDay = Box("")
    let age = Box("")
    let diariesCount = Box(0)
    let followersCount = Box(0)
    let likedCount = Box(0)
    let isFollowed = Box(false)
    let isBlocked = Box(false)
    let diaries = Box([Diary]())
    var gotData: (() -> Void)?
    var ownerUserId = Box("")

    init(petId: String) {

        self.petId.value = petId

        print("ProfileVM Start Getting pet form \(petId) ...")
        FirebaseManager.shared.fetchPet(petId: petId) { result in

            switch result {

            case .success(let pet):

                self.petImageThumbnailUrl.value = pet.petThumbnail?.url ?? "Error pet's Url"
                self.petName.value = pet.name
                self.age.value = Date().getAge(from: pet.healthInfo.birthday)
                self.birthDay.value = pet.healthInfo.birthday
                if let followers = pet.followers {
                    self.followersCount.value = followers.count
                    if followers.contains(FirebaseManager.userId) {
                        self.isFollowed.value = true
                    } else {
                        self.isFollowed.value = false
                    }
                } else {
                    self.isFollowed.value = false
                }
                self.likedCount.value = pet.liked ?? 0
                self.ownerUserId.value = pet.userId

                FirebaseManager.shared.fetchPetAllDiaries(petId: pet.petId) { result in

                    switch result {

                    case .success(let diaries):
                        self.likedCount.value = 0
                        self.diaries.value = diaries
                        self.diariesCount.value = diaries.count
                        diaries.forEach { diary in
                            self.likedCount.value += diary.whoLiked.count
                        }
                        self.gotData?()

                    case .failure(let error):

                        print("Get pet's Diaries Error /n \(error)")

                    }

                }

            case .failure(let error):

                print("Get pet's Info Error /n \(error)")

            }
        }
    }
}
