//
//  NewPostDescriptionController.swift
//  Course3FinalTask
//
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit

class NewPostDescriptionController: UIViewController {
    
    @IBOutlet weak var chosenImageView: UIImageView! {
        didSet {
            chosenImageView.image = finalImage
        }
    }
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var finalImage: UIImage?
    var networkService = NetworkService()
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        Spinner.start()
        guard let image = finalImage, let description = descriptionTextField.text else { return }
        
        createPost(image: image, description: description, completion: { [weak self] newPost in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard let navController = self.tabBarController?.viewControllers?.first as? UINavigationController else { return }
                guard let destinationController = navController.childViewControllers.first as? FeedViewController else { return }
                
                destinationController.navigationController?.popToRootViewController(animated: true)
                Posts.list.insert(newPost, at: 0)
                destinationController.feedTableView.reloadData()
                destinationController.feedTableView.layoutIfNeeded()
                destinationController.feedTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
                self.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)
                Spinner.stop()
            }
        } )

    }
    
    private func createPost(image: UIImage, description: String, completion: @escaping (Post) -> ()) {
     guard let token = SecureStorableService.safeReadToken() else {
         print("Cannot read token from keychain")
         AlertController.showError()
         return
     }
        let image = image
        let description = description
        //var post: Post?
        
        networkService.createPostRequest(token: token, image: image, description: description, completion: { createdPost, errorMessage in
            if let post = createdPost {
                completion(post)
            }
            else if let message = errorMessage {
            AlertController.showError(with: message)
            }
            else {
             AlertController.showError()
                }
        })
    }

}
