//
//  PhotoCollectionViewCell.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var pictureImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pictureImageView.frame = bounds
    }
    
    func setPicture(_ post: Post) {
        pictureImageView.image = post.image
    }
    
    func configure(with photo: UIImage) {
        pictureImageView.image = photo
        setNeedsLayout()
    }
}
