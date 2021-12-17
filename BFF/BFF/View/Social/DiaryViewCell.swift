//
//  DiaryViewCell.swift
//  BFF
//
//  Created by yulin on 2021/12/17.
//

import Foundation
import UIKit

protocol SocialDiaryCellDelegate: AnyObject {

    func didTapLiked(cell: DiaryViewCell, indexPath: Int)

    func didTapMoreButton(cell: DiaryViewCell, indexPath: Int)

    func didTapComment(cell: DiaryViewCell, indexPath: Int)

    func didTapSendMessageButton(cell: DiaryViewCell, indexPath: Int)

    func didTapPetButton(cell: DiaryViewCell, indexPath: Int)

    func didTapSettingButton(cell: DiaryViewCell, indexPath: Int)

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

    weak var delegate: SocialDiaryCellDelegate?
    var indexPath = 0
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

            self.checkCommentLabelHeight()

            self.diaryImageView.loadImage( diary.images.first?.url)

            self.dateLabel.text = "\(diary.createdTime.dateValue().toString())"

            self.diaryContentLabel.text = "\(diary.content)"

            self.likeLabel.text = "\(diary.whoLiked.count)"

            if diary.whoLiked.contains(FirebaseManager.shared.userId) {
                self.likeIcon.image = UIImage(systemName: "heart.fill")

            } else {
                self.likeIcon.image = UIImage(systemName: "heart")

            }

            if diary.userId == FirebaseManager.shared.userId {
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

    private func checkCommentLabelHeight() {
        if self.diaryContentLabel.isTruncated() {
            self.moreButton.isHidden = false
        } else {
            self.moreButton.isHidden = true
        }
    }

    @objc func tapsendMessageButton() {

        delegate?.didTapSendMessageButton(cell: self, indexPath: indexPath)

    }

    @objc func tapPetButton() {

        delegate?.didTapPetButton(cell: self, indexPath: indexPath)

    }

    @objc func tapLikedButton() {

        delegate?.didTapLiked(cell: self, indexPath: indexPath)
    }

    @objc func tapCommentButton() {
        delegate?.didTapComment(cell: self, indexPath: indexPath)
    }

    @objc func tapSettingButton() {

        delegate?.didTapSettingButton(cell: self, indexPath: indexPath)
    }

    @IBAction func showMore(_ sender: UIButton) {

        delegate?.didTapMoreButton(cell: self, indexPath: indexPath)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        checkCommentLabelHeight()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}
