//
//  DiaryDeatilViewController.swift
//  BFF
//
//  Created by yulin on 2021/10/19.
//

import UIKit

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var contentTextView: UITextView!

    @IBOutlet weak var postPetImageView: UIImageView!

    @IBOutlet weak var postPetNameLabel: UILabel!

    @IBOutlet weak var createdTimeLabel: UILabel!

    @IBOutlet weak var tagStackView: UIStackView!

    @IBOutlet weak var ccommentImage: UIImageView!

    @IBOutlet weak var commentLabel: UILabel!

    @IBOutlet weak var settingButton: UIButton!

    var viewModel = DetialViewModel()
    var comments = [String]()
    var petTags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        postPetImageView.layer.cornerRadius = postPetImageView.frame.height / 2

        viewModel.postPetImageUrl.bind {  [weak self] urlStr in
            self?.image.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.contentText.bind {  [weak self] content in
            self?.contentTextView.text = content
        }

        viewModel.postPetImageUrl.bind {  [weak self] urlStr in
            self?.postPetImageView.kf.setImage(with: URL(string: urlStr))
        }

        viewModel.postPetsName.bind {  [weak self] name in
            self?.postPetNameLabel.text = name
        }

        viewModel.creatDate.bind {  [weak self] dateStr in
            self?.createdTimeLabel.text = dateStr
        }

        viewModel.numberOfComments.bind {  [weak self] count in
            self?.commentLabel.text = "\(count)"
        }

        viewModel.comments.bind {  [weak self] comments in
            self?.comments = comments
        }

        viewModel.petTags.bind {  [weak self] petTags in
            self?.petTags = petTags
        }

    }

    func setPetsTag(){
        tagStackView.subviews.forEach { subview in
            tagStackView.removeArrangedSubview(subview)
        }
        petTags.forEach { petName in
            let tag = UILabel()
            tag.text = petName
            tagStackView.addArrangedSubview(tag)
        }
    }

}
