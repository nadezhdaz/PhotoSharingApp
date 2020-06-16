//
//  NewPostDescriptionController.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

class NewPostDescriptionController: UIViewController, SecureStorable {
    
    @IBOutlet weak var chosenImageView: UIImageView! {
        didSet {
            chosenImageView.image = finalImage
        }
    }
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var finalImage: UIImage?
    var queue: DispatchQueue? = DispatchQueue(label: "com.myqueues.customQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global(qos: .userInteractive))
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        Spinner.start()
        let image = finalImage
        let description = descriptionTextField.text
        
        if image != nil && description != nil {
            
            let newPost = createPost(image: finalImage, description: description)
            
            guard let navController = self.tabBarController?.viewControllers?.first as? UINavigationController else { return }
            guard let destinationController = navController.childViewControllers.first as? FeedViewController else { return }
            
            destinationController.navigationController?.popToRootViewController(animated: true)
            Posts.list.insert(newPost?, at: 0)
            destinationController.feedTableView.reloadData()
            destinationController.feedTableView.layoutIfNeeded()
            destinationController.feedTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popToRootViewController(animated: true)
            
            
        }
        
        /*
    if finalImage != nil && descriptionTextField.text != nil {
        DataProviders.shared.postsDataProvider.newPost(with: finalImage!, description: descriptionTextField.text!, queue: self.queue, handler: { [weak self] newPost in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if newPost != nil {
                    guard let navController = self.tabBarController?.viewControllers?.first as? UINavigationController else { return }
                    guard let destinationController = navController.childViewControllers.first as? FeedViewController else { return }
                    
                    destinationController.navigationController?.popToRootViewController(animated: true)
                    Posts.list.insert(newPost!, at: 0)
                    destinationController.feedTableView.reloadData()
                    destinationController.feedTableView.layoutIfNeeded()
                    destinationController.feedTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
                    self.tabBarController?.selectedIndex = 0
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    self.showError()
                }
                Spinner.stop()
            }
        })
        
        
    }
         */
    }

}
