//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var usernameTitle: UINavigationItem! //{
    @IBOutlet weak var photosCollectionView: UICollectionView!

    var userPosts: [Post] = []
    var user: User?
    var currentUser: User?
    var isCurrentUserProfile: Bool = false
    var networkService = NetworkService()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserPosts()
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
        guard let user = user else { return }
        
        if user.currentUserFollowsThisUser {
            self.unfollowUser(userID: user.id, completion: { [weak self] user in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.user?.followedByCount -= 1
                    self.currentUser!.followsCount -= 1
                    self.user?.currentUserFollowsThisUser = false
                    view.updateFollows(user)
                }
            })
        }
        else {
            self.followUser(userID: user.id, completion: { [weak self] user in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.user?.followedByCount += 1
                    self.currentUser!.followsCount += 1
                    self.user?.currentUserFollowsThisUser = true
                    view.updateFollows(user)
                }
            })
        }
        
    }
    
    func profileToFollowersListSegue(_ view: HeaderCollectionViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListController else { return }
        destinationController.listIdentifier = "followers"
        Spinner.start()
        getUserInfo(userID: view.authorID, completion: { user in
            DispatchQueue.main.async {
                destinationController.user = user
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
    func profileToFollowingListSegue(_ view: HeaderCollectionViewCell) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "userListVC") as? UserListController else { return }
        destinationController.listIdentifier = "following"
        Spinner.start()
        getUserInfo(userID: view.authorID, completion: { user in
            DispatchQueue.main.async {
                destinationController.user = user
            }
        })
        
        self.navigationController!.pushViewController(destinationController, animated: true)
    }
    
    private func setupUserPosts() {
        Spinner.start()
        
        getCurrentUserInfo(completion: { [weak self] currentUser in
            DispatchQueue.main.async {
                if self?.user == nil {
                    self?.user = currentUser
                }
                self?.currentUser = currentUser
                
                if self?.user?.id == currentUser.id {
                    self?.isCurrentUserProfile = true
                    self?.addLogoutButton()
                }
                
                guard let user = self?.user else { return }
                    
                self?.getPostsOfUser(userID: user.id, completion: { [weak self] posts in
                    DispatchQueue.main.async {
                        self?.userPosts = posts
                        self?.photosCollectionView.layoutIfNeeded()
                        self?.photosCollectionView.reloadData()
                        Spinner.stop()
                    }
                    
                })
                
                self?.usernameTitle.title = self?.user?.username
                self?.photosCollectionView.register(cellType: PhotoCollectionViewCell.self)
                self?.photosCollectionView.register(viewType: HeaderCollectionViewCell.self, kind:     UICollectionView.elementKindSectionHeader)
                self?.photosCollectionView.delegate = self
                self?.photosCollectionView.dataSource = self
                self?.photosCollectionView.reloadData()
                
            }
            
        })
    }
    
    @objc func logoutTapped() {
        userSignOut()
        switchToAuthorizationViewController()
    }
    
    private func switchToAuthorizationViewController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authorizationViewController = mainStoryboard.instantiateViewController(withIdentifier: "authorizationVC") as? AuthorizationViewController else { return }
        let window = UIApplication.shared.windows.first
        window?.rootViewController = authorizationViewController
        window?.makeKeyAndVisible()
    }
    
    private func addLogoutButton() {
        let logoutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logoutTapped))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func getCurrentUserInfo(completion: @escaping (User) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
         print("Cannot read token from keychain")
         AlertController.showError()
         return
     }
        
        networkService.currentUserInfoRequest(token: token, completion: { result in
            switch result {
            case .success(let currentUser):
                completion(currentUser)
            case .failure(let error):
                AlertController.showError(for: error)
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
        
        networkService.userInfoRequest(token: token, userID: userID, completion: { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
    private func followUser(userID: String, completion: @escaping (User) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            AlertController.showError()
         return
        }
        let userID = userID
        
        networkService.followUserRequest(token: token, userID: userID, completion: { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
    private func unfollowUser(userID: String, completion: @escaping (User) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            AlertController.showError()
         return
        }
        let userID = userID
        
        networkService.unfollowUserRequest(token: token, userID: userID, completion: { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
    private func getPostsOfUser(userID: String, completion: @escaping ([Post]) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            AlertController.showError()
            return
        }
        let userID = userID
        
        networkService.getPostsOfUserRequest(token: token, userID: userID, completion: { result in
            switch result {
            case .success(let posts):
                completion(posts)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
    private func userSignOut() {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            return
        }
        networkService.signOutRequest(token: token, completion: { result in
            switch result {
            case .success(_):
                print("Signed out")
            case .failure(let error):
                AlertController.showError(for: error)
            }
            
        })
    }
}
