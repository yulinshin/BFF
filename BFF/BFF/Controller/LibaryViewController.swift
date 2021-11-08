//
//  LibaryViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/3.
//

import UIKit

class LibaryViewController: UIViewController {


    var bookViewModels = [BookViewModel(icon: "Hospital", title: "全台動物醫院地圖", subtitle: "24小時動物醫院、特殊寵物動物醫院")]


    @IBOutlet weak var libaryCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

        libaryCollectionView.delegate = self
        libaryCollectionView.dataSource = self

    }

}

extension LibaryViewController:UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        bookViewModels.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = libaryCollectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as? BookCollectionViewCell else { return UICollectionViewCell() }

        cell.model = bookViewModels[indexPath.row]
        cell.makeBookCover()
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch bookViewModels[indexPath.row].title.value {

        case "全台動物醫院地圖":

            let storyboard = UIStoryboard(name: "Libary", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }



            self.navigationController?.pushViewController(controller, animated: true)
        default:
            break

        }


    }

}
