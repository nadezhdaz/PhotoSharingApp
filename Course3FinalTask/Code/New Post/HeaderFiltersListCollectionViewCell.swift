//
//  HeaderFiltersListCollectionViewCell.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 06/05/2019.
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

class HeaderFiltersListCollectionViewCell: UICollectionReusableView {
    
    @IBOutlet weak var chosenImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chosenImage.frame = bounds
    }
    
    public func setImage(_ image: UIImage)
    {
        chosenImage.image = image
    }
}
