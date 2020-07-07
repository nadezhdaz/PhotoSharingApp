//
//  FiltersListCollectionViewCell.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

class FiltersListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var filterPreviewImageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    public var filterFullName: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()        
    }
    
    func create(with filter: FilterPreview) {
        
        filterFullName = filter.name
        
        if filter.image != nil {
        filterPreviewImageView.image = filter.image
        }
        
        if filter.name == "CISepiaTone" {
            filterNameLabel.text = "SepiaTone"
        }
        else {
            let index = filter.name.index(filter.name.startIndex, offsetBy: 13)
            filterNameLabel.text = String(filter.name[index...])
        }
    }
    
}
