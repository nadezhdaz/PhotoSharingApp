//
//  AlertController.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 19.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class AlertController: UIViewController {
    
    static func showLocalError() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Unknown error", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func showError() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Transfer error", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func showError(with message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in }))
            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
}
