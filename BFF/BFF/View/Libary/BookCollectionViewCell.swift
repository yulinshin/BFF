//
//  BookCollectionViewCell.swift
//  BFF
//
//  Created by yulin on 2021/11/3.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bookCoverBackground: UIView!
    @IBOutlet weak var bookIconImageView: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookSubTitle: UILabel!

    var model: BookViewModel?


    func makeBookCover() {

        guard let model = model else { return
        }

        model.icon.bind { urlStr in
            self.bookIconImageView.loadImage(urlStr, placeHolder: UIImage(named: "vet"))
        }

        model.title.bind { title in
            self.bookTitle.text = title
        }

        model.subtitle.bind { subtitle in
            self.bookSubTitle.text = subtitle
        }

    }

    func setLayout(){

        bookCoverBackground.layer.cornerRadius = 10
        bookCoverBackground.backgroundColor = .white
        bookCoverBackground.layer.shadowOffset = CGSize(width: 4, height: 4)
        bookCoverBackground.layer.shadowColor = UIColor.gray.cgColor

        bookCoverBackground.layer.shadowRadius = 10
        bookCoverBackground.layer.shadowOpacity = 0.2

    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }


}
