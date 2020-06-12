//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cellHeights: [IndexPath : CGFloat] = [:]
    var queue: DispatchQueue? = DispatchQueue(label: "com.myqueues.customQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global(qos: .userInteractive))

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
        //let likesHandler = LikesHandler()
        
        postCell.setPost(post)
        postCell.profileTapHandler = { [unowned self] in
            
            self.feedToProfileSegue(postCell)
        }
        postCell.likesCounterTapHandler = { [unowned self] in
            self.feedToUserListSegue(postCell)
        }
        postCell.likeButtonTapHandler = { [unowned self] in
            self.likingHandler(postCell)
            //likesHandler.likeHandler(postCell, self.feedTableView)
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
        return cellHeights[indexPath] ?? UITableViewAutomaticDimension
    }
    
    func likingHandler(_ cell: FeedTableViewCell) {
        
        guard let post = cell.currentPost else { return }
        
        if !(post.currentUserLikesThisPost) {
            
            cell.bigLikeAnimation()
            DataProviders.shared.postsDataProvider.likePost(with: cell.postID, queue: self.queue, handler: { [weak self] incomingPost in
                 guard let self = self else { return }
                if incomingPost != nil {
                    DispatchQueue.main.async {
                        cell.updateLikes(post)
                    }
                }
                else {
                    self.showError()
                }
            })
            
        } else {
            
            DataProviders.shared.postsDataProvider.unlikePost(with: cell.postID, queue: self.queue, handler: { [weak self] incomingPost in
                 guard let self = self else { return }
                if incomingPost != nil {
                    DispatchQueue.main.async {
                        cell.updateLikes(post)
                    }
                }
                else {
                    showError()
                }
            })
            
        }
        
        DataProviders.shared.postsDataProvider.feed(queue: self.queue, handler: { [weak self] incomingPosts in
            guard let self = self else { return }
                           DispatchQueue.main.async {
                               if incomingPosts != nil {
                                Posts.list = incomingPosts!
                                self.feedTableView.reloadData()
                                self.feedTableView.layoutIfNeeded()
                               }
                               else {
                                   showError()
                            }
                            
            }
            
        })
        
    }

    
    func feedToProfileSegue(_ cell: FeedTableViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else { return }
        Spinner.start()
        DataProviders.shared.usersDataProvider.user(with: cell.authorID, queue: self.queue, handler: { [weak self] incomingUser in
            DispatchQueue.main.async {
            if incomingUser != nil {
                destinationController.user = incomingUser!
            }
            else {
                self?.showError()                }
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
        
    }
    
    func feedToUserListSegue(_ cell: FeedTableViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListController else { return }
        destinationController.listIdentifier = "likes"
        Spinner.start()
        DataProviders.shared.usersDataProvider.user(with: cell.authorID, queue: self.queue, handler: { [weak self] incomingUser in
            DispatchQueue.main.async {
            if incomingUser != nil {
                destinationController.user = incomingUser!
            }
            else {
                self?.showError()
                }
            }
        })
        Spinner.start()
        DataProviders.shared.postsDataProvider.post(with: cell.postID, queue: self.queue, handler: { [weak self] incomingPost in
            DispatchQueue.main.async {
            if incomingPost != nil {
                destinationController.post = incomingPost!
            }
            else {
                self?.showError()
                }
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
    private func setupPosts() {
        Spinner.start()
        
        DataProviders.shared.postsDataProvider.feed(queue: self.queue, handler: { [weak self] incomingPosts in
            DispatchQueue.main.async {
                if incomingPosts != nil {
                    Posts.list = incomingPosts!
                    self?.feedTableView.reloadData()
                    self?.feedTableView.layoutIfNeeded()
                }
                else {
                    self?.showError()
                }
                Spinner.stop()
            }
        })
    }
    
}
