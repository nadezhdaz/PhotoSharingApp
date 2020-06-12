//
//  FilterImageOperation.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class FilterImageOperation: Operation {
    
    private var _inputImage: UIImage?
    private(set) var outputImage: UIImage?
    private var _chosenFilter: String?
    
    init(inputImage: UIImage?, filter: String) {
        self._chosenFilter = filter
        self._inputImage = inputImage
    }
    
    override func main() {
        
        let context = CIContext()
        
        guard let coreImage = CIImage(image: _inputImage!) else { return }
        
        guard let filter = CIFilter(name: _chosenFilter!) else { return }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        
        guard let filteredImage = filter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(filteredImage,
                                                  from: filteredImage.extent) else { return }
        
        outputImage = UIImage(cgImage: cgImage)
    }
}
