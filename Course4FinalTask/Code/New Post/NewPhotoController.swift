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
    var pathes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPhotos()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = newPhotoCollectionView.dequeueCell(of: PhotoCollectionViewCell.self, for: indexPath)
        let path = photos[indexPath.row]
        let image = UIImage(contentsOfFile: path)
        photoCell.configure(with: image!)        
        return photoCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let path = photos[indexPath.row]
        newPostToFiltersListSegue(path: path)
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
    
    private func setPhotos() {
        let filemanager = FileManager.default
        guard let path = Bundle.main.resourcePath else { return }
        let imagePath = path + "/new"
        if let photosArray = try? filemanager.contentsOfDirectory(atPath: imagePath) {
            for item in photosArray {
                if let bundlePath = Bundle.main.path(forResource: item, ofType: nil, inDirectory: "new") {
                    self.photos.append(bundlePath)
                }
            }
        }
    }
    
    private func newPostToFiltersListSegue(path: String) {
        let path = path
        let image = UIImage(contentsOfFile: path)
        
        guard let destinationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filtersPreviewVC") as? FiltersListController else { return }
        guard let navigationController = navigationController  else { return }
        destinationController.chosenImage = image
        destinationController.imageFilterPreview = image?.resized(toWidth: 50.0)
        navigationController.pushViewController(destinationController, animated: true)
    }
    
}

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
