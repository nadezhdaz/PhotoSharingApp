//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import DataProvider

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var usernameTitle: UINavigationItem! //{
     //   didSet {
     //       usernameTitle.title = user?.username
     //   }
   // }
    @IBOutlet weak var photosCollectionView: UICollectionView! //{
     //   didSet {
     //       photosCollectionView.register(UINib(nibName: String(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: //PhotoCollectionViewCell.self))
     //       photosCollectionView.register(UINib(nibName: String(describing: HeaderCollectionViewCell.self), bundle: nil), forSupplementaryViewOfKind: //UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: HeaderCollectionViewCell.self))
     //
     //       photosCollectionView.delegate = self
     //       photosCollectionView.dataSource = self
     //       photosCollectionView.reloadData()
     //   }
   // }
    
    var userPosts: [Post] = []
    var user: User?
    var currentUser: User?
    var isCurrentUserProfile: Bool = false
    var queue: DispatchQueue? = DispatchQueue(label: "com.myqueues.customQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global(qos: .userInteractive))
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUser()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueCell(of: PhotoCollectionViewCell.self, for: indexPath)
        
        cell.setPicture(userPosts[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = photosCollectionView.dequeueSupplementaryView(of: HeaderCollectionViewCell.self, kind: kind, for: indexPath)
        
        view.setHeader(user!, isCurrentUserProfile)
        view.followButtonTapHandler = { [unowned self] in
            self.followButtonHandler(view)
        }
        view.followersLabelTapHandler = { [unowned self] in
            self.profileToFollowersListSegue(view)
        }
        view.followingLabelTapHandler = { [unowned self] in
            self.profileToFollowingListSegue(view)
        }
        
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemSize = (UIScreen.main.bounds.width / 3)
        
        return CGSize(width: itemSize, height: itemSize)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func followButtonHandler(_ view: HeaderCollectionViewCell) {
        guard user != nil && currentUser != nil else { return }
        
        if user!.currentUserFollowsThisUser {
            DataProviders.shared.usersDataProvider.unfollow(user!.id, queue: self.queue, handler: { [weak self] incomingUser in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if incomingUser != nil {
                        self.user!.followedByCount -= 1
                        self.currentUser!.followsCount -= 1
                        self.user!.currentUserFollowsThisUser = false
                        view.updateFollows(incomingUser!)
                    }
                    
                }
                
            })
            
        }
        else {
            DataProviders.shared.usersDataProvider.follow(user!.id, queue: self.queue, handler: { [weak self] incomingUser in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if incomingUser != nil {
                        self.user!.followedByCount += 1
                        self.currentUser!.followsCount += 1
                        self.user!.currentUserFollowsThisUser = true
                        view.updateFollows(incomingUser!)
                    }
                    
                }
                
            })
        }
        
    }
    
    func profileToFollowersListSegue(_ view: HeaderCollectionViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListController else { return }
        destinationController.listIdentifier = "followers"
        Spinner.start()
        DataProviders.shared.usersDataProvider.user(with: view.authorID, queue: self.queue, handler: { [weak self] incomingUser in
            guard let self = self else { return }
            DispatchQueue.main.async {
            if incomingUser != nil {
                destinationController.user = incomingUser!
            }
            else {
                self.showError()
                }
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
    func profileToFollowingListSegue(_ view: HeaderCollectionViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListController else { return }
        destinationController.listIdentifier = "following"
        Spinner.start()
        DataProviders.shared.usersDataProvider.user(with: view.authorID, queue: self.queue, handler: { [weak self] incomingUser in
            guard let self = self else { return }
            DispatchQueue.main.async {
            if incomingUser != nil {
                destinationController.user = incomingUser!
            }
            else {
                self.showError()
                }
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
    private func setupUser() {
        Spinner.start()
        DataProviders.shared.usersDataProvider.currentUser(queue: self.queue, handler: { [weak self] currentUser in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if currentUser != nil {
                    if self.user == nil {
                        self.user = currentUser!
                    }
                    self.currentUser = currentUser!
                    if self.user?.id == currentUser?.id {
                        self.isCurrentUserProfile = true
                    }
                    
                    DataProviders.shared.postsDataProvider.findPosts(by: self.user!.id, queue: self.queue, handler: { [weak self] incomingPosts in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if incomingPosts != nil {
                                self.userPosts = incomingPosts!
                                self.photosCollectionView.layoutIfNeeded()
                                self.photosCollectionView.reloadData()
                            }
                            else {
                                self.showError()
                            }
                            Spinner.stop()
                        }
                    })
                }
                else {
                    self.showError()
                }
                
                self.usernameTitle.title = self.user!.username
                self.photosCollectionView.register(cellType: PhotoCollectionViewCell.self)
                self.photosCollectionView.register(viewType: HeaderCollectionViewCell.self, kind: UICollectionElementKindSectionHeader)
                
                self.photosCollectionView.delegate = self
                self.photosCollectionView.dataSource = self
                self.photosCollectionView.reloadData()
                
            }
        })
    }
    
}
