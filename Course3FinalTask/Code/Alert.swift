//
//  Alert.swift
//  Course2FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Unknown error!", message: "Please, try again later.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self?.navigationController?.popViewController(animated: true) }))
            self?.present(alertController, animated: true)            
        }
    }
    
    func showError(with message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self?.navigationController?.popViewController(animated: true) }))
            self?.present(alertController, animated: true)
        }
    }
}

class AlertController {
    
    static func getAlert(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Unknown error", message: "Please, try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        return alert
    }
 
 }
