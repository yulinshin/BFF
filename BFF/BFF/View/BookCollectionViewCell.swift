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
            self.bookIconImageView.loadImage(urlStr, placeHolder: UIImage())
        }

        model.title.bind { title in
            self.bookTitle.text = title
        }

        model.subtitle.bind { subtitle in
            self.bookSubTitle.text = subtitle
        }

        setLayout()

    }

    func setLayout(){

        bookCoverBackground.layer.cornerRadius = 10
        bookCoverBackground.layer.shadowColor = UIColor.gray.cgColor
        bookCoverBackground.layer.shadowOffset = CGSize(width: 10, height: 10)

    }


}
