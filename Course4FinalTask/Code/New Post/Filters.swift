//
//  Filters.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

public struct Filters {
    
    let filterArray = ["CIPhotoEffectChrome" , "CIPhotoEffectFade", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CISepiaTone"]
}

public struct FilterPreview: Equatable {
   public var image: UIImage?
   public var name: String
    
    init(image: UIImage?, name: String) {
        self.image = image
        self.name = name
    }
    
    init(name: String) {
        self.name = name
    }
}
