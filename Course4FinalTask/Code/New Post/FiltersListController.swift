//
//  FiltersListController.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

class FiltersListController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imagePreview: UIImageView! {
        didSet {
            imagePreview.image = chosenImage
        }
    }
    @IBOutlet weak var filtersPreviewCollection: UICollectionView!
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard let destinationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "descriptionVC") as? NewPostDescriptionController  else { return }
        guard let navigationController = navigationController else { return }
        destinationController.finalImage = imagePreview.image
        navigationController.pushViewController(destinationController, animated: true)
    }
    
    let queue = OperationQueue()
    let filters = Filters().filterArray
    var imageFilterPreview: UIImage?
    var chosenImage: UIImage?
    var filtersOutput = [FilterPreview]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFilters()
            
        self.filtersPreviewCollection.register(UINib(nibName: String(describing: FiltersListCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: FiltersListCollectionViewCell.self))
           
        self.filtersPreviewCollection.delegate = self
        self.filtersPreviewCollection.dataSource = self
        self.filtersPreviewCollection.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtersOutput.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = filtersPreviewCollection.dequeueReusableCell(withReuseIdentifier: String(describing: FiltersListCollectionViewCell.self), for: indexPath) as! FiltersListCollectionViewCell
        
        filterCell.create(with: filtersOutput[indexPath.row])
        
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Spinner.start()
        
        let selectedCell = filtersPreviewCollection.cellForItem(at: indexPath) as! FiltersListCollectionViewCell
        guard let chosenFilter = selectedCell.filterFullName else { return }
        
        let operation = FilterImageOperation(inputImage: self.chosenImage, filter: chosenFilter)
        
        operation.completionBlock = {
            
            DispatchQueue.main.async {                
                self.imagePreview.image = operation.outputImage
                Spinner.stop()
            }
        }
        
        self.queue.addOperation(operation)
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 120, height: 120)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 100.0
    }
    
    private func setupFilters() {
        for filter in filters {
            filtersOutput.append(FilterPreview(name: filter))
        }
        
        Spinner.start()
        DispatchQueue.main.async {
            
            for filter in self.filters {
                
                let imagePreview = self.imageFilterPreview
                let operation = FilterImageOperation(inputImage: imagePreview, filter: filter)
                
                operation.completionBlock = {
                    
                    DispatchQueue.main.async {
                        
                        let newPreview = FilterPreview(image: operation.outputImage, name: filter)
                        
                        guard let index = self.filtersOutput.firstIndex(of: FilterPreview(name: filter)) else { return }
                        
                        let indexPosition = IndexPath(row: index, section: 0)
                        self.filtersOutput[index] = newPreview
                        self.filtersPreviewCollection.reloadItems(at: [indexPosition])
                    }
                }
                self.queue.addOperation(operation)
            }
        }
        
        self.queue.waitUntilAllOperationsAreFinished()
        
        Spinner.stop()
    }
    
}


