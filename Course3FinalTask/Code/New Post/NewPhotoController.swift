//
//  NewPhotoController.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

class NewPhotoController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var newPhotoCollectionView: UICollectionView! {
        didSet {
            newPhotoCollectionView.register(cellType: PhotoCollectionViewCell.self)
            newPhotoCollectionView.delegate = self
            newPhotoCollectionView.dataSource = self
        }
    }
    
    var photos = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPhotos()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = newPhotoCollectionView.dequeueCell(of: PhotoCollectionViewCell.self, for: indexPath)
        
        photoCell.configure(with: photos[indexPath.row])
        
        return photoCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = photos[indexPath.row]
        
        guard let destinationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filtersPreviewVC") as? FiltersListController else { return }
        guard let navigationController = navigationController  else { return }
        destinationController.chosenImage = image
        destinationController.imageIndex = indexPath.row
        navigationController.pushViewController(destinationController, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = (UIScreen.main.bounds.width / 3)
        
        return CGSize(width: itemSize, height: itemSize)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    private func setPhotos()  {
        if let path = Bundle.main.resourcePath {
            let imagePath = path + "/new"
            let filemanager = FileManager.default
            let photosArray = try! filemanager.contentsOfDirectory(atPath: imagePath)

            for item in photosArray {
                self.photos.append(item)
            }
        }
    }
    
}
