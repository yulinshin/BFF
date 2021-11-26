//
//  LibraryViewController.swift
//  BFF
//
//  Created by yulin on 2021/11/3.
//

import UIKit

class LibraryViewController: UIViewController {


    var bookViewModels = [BookViewModel(icon: "Hospital", title: "全台動物醫院地圖", subtitle: "24小時動物醫院、特殊寵物動物醫院")]

    @IBOutlet weak var libraryCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        libraryCollectionView.delegate = self
        libraryCollectionView.dataSource = self

        self.navigationController?.navigationBar.tintColor = UIColor.mainColor
        navigationController?.navigationBar.barTintColor = UIColor.mainColor

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

}

extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        bookViewModels.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = libraryCollectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as? BookCollectionViewCell else { return UICollectionViewCell() }

        cell.model = bookViewModels[indexPath.row]
        cell.makeBookCover()
        cell.setLayout()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch bookViewModels[indexPath.row].title.value {

        case "全台動物醫院地圖":

            let storyboard = UIStoryboard(name: "Library", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
            controller.title = "全台動物醫院"
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            break

        }

    }

}
