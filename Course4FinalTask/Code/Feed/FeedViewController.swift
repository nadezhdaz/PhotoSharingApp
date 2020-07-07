//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellHeights: [IndexPath : CGFloat] = [:]
    var networkService = NetworkService()
    
    @IBOutlet weak var feedTableView: UITableView! {
        didSet {
            feedTableView.register(UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedTableViewCell.self))
            feedTableView.delegate = self
            feedTableView.dataSource = self
            feedTableView.allowsSelection = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPosts()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Posts.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedTableViewCell.self)) as! FeedTableViewCell
        let post = Posts.list[indexPath.row]
        
        postCell.setPost(post)
        postCell.profileTapHandler = { [unowned self] in
            self.feedToProfileSegue(postCell)
        }
        postCell.likesCounterTapHandler = { [unowned self] in
            self.feedToUserListSegue(postCell)
        }
        postCell.likeButtonTapHandler = { [unowned self] in
            self.likingHandler(postCell)
        }
        
        return postCell
    }
    
    // MARK: - UITableViewDelegate
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
    
    func likingHandler(_ cell: FeedTableViewCell) {
        guard let post = cell.currentPost else { return }
        
        if !(post.currentUserLikesThisPost) {
            likePost(postID: cell.postID, completion: { [weak self] post in
                DispatchQueue.main.async {
                    cell.updateLikes(post)
                    self?.updatePosts()
                }
            })
            
        } else {
            unlikePost(postID: cell.postID, completion: { [weak self] post in
                DispatchQueue.main.async {
                    cell.updateLikes(post)
                    self?.updatePosts()
                }
            })
            
        }
        
        
        
    }

    
    private func feedToProfileSegue(_ cell: FeedTableViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else { return }
        Spinner.start()
        getUserInfo(userID: cell.authorID, completion: { user in
            DispatchQueue.main.async {
                destinationController.user = user
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
        
    }
    
    private func feedToUserListSegue(_ cell: FeedTableViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListController else { return }
        destinationController.listIdentifier = "likes"
        Spinner.start()
        getUserInfo(userID: cell.authorID, completion: { user in
            DispatchQueue.main.async {
                destinationController.user = user
                
                self.getPost(postID: cell.postID, completion: { post in
                    DispatchQueue.main.async {
                        destinationController.post = post
                        self.navigationController!.pushViewController(destinationController, animated: true)
                    }
                })
            }
        })
    }
    
    private func setupPosts() {
        Spinner.start()
        
        getFeed(completion: { [weak self] feed in
            DispatchQueue.main.async {
                Posts.list = feed
                self?.feedTableView.reloadData()
                self?.feedTableView.layoutIfNeeded()
                Spinner.stop()
            }
        })
    }
    
    private func updatePosts() {
        getFeed(completion: { [weak self] incomingPosts in
            guard let self = self else { return }
            DispatchQueue.main.async {
                Posts.list = incomingPosts
                self.feedTableView.reloadData()
                self.feedTableView.layoutIfNeeded()
            }
        })
    }
    
    private func getUserInfo(userID: String, completion: @escaping (User) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            AlertController.showError()
         return
        }
        let userID = userID
        
        networkService.userInfoRequest(token: token, userID: userID, completion: { user, errorMessage in
            if let user = user {
                completion(user)
            }
            else if let message = errorMessage {
            AlertController.showError(with: message)
            }
            else {
             AlertController.showError()
                }
        })
    }
    
    private func getFeed(completion: @escaping ([Post]) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            return            
        }
          
          networkService.getFeedRequest(token: token, completion: { posts, errorMessage in
              if let feed = posts {
                  completion(feed)
              }
              else if let message = errorMessage {
              AlertController.showError(with: message)
              }
              else {
                AlertController.showError()
                  }
          })
      }
    
    private func getPost(postID: String, completion: @escaping (Post) -> ()) {
     guard let token = SecureStorableService.safeReadToken() else {
         print("Cannot read token from keychain")
         AlertController.showError()
         return
     }
        let postID = postID
        
        networkService.getPostRequest(token: token, postID: postID, completion: { receivedPost, errorMessage in
            if let post = receivedPost {
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
    
    private func likePost(postID: String, completion: @escaping (Post) -> ()) {
     guard let token = SecureStorableService.safeReadToken() else {
         print("Cannot read token from keychain")
         AlertController.showError()
         return
     }
        let postID = postID
        
        networkService.likePostRequest(token: token, postID: postID, completion: { likedPost, errorMessage in
            if let post = likedPost {
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
    
    private func unlikePost(postID: String, completion: @escaping (Post) -> ()) {
     guard let token = SecureStorableService.safeReadToken() else {
         print("Cannot read token from keychain")
         AlertController.showError()
         return
     }
        let postID = postID
        
        networkService.unlikePostRequest(token: token, postID: postID, completion: { unlikedPost, errorMessage in
            if let post = unlikedPost {
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
    
    public func scrollToFirstRow() {
      let indexPath = IndexPath(row: 0, section: 0)
      self.feedTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
}
