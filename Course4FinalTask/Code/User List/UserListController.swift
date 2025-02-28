//
//  UserListController.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class UserListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var userListTableView: UITableView!
    @IBOutlet weak var userListNavigationItem: UINavigationItem!
    
    var user: User?
    var post: Post?
    var users: [User] = []
    var userIDs: [User] = []
    var listIdentifier: String = ""
    var networkService = NetworkService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        setupList()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserListCell.self)) as! UserListCell
        
        cell.setUser(users[indexPath.row])
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else { return }
        destinationController.user = users[indexPath.row]
        self.navigationController!.pushViewController(destinationController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func setupList() {
        getCurrentUserInfo(completion: { [weak self] currentUser in
            DispatchQueue.main.async {
                if self?.user == nil {
                    self?.user = currentUser
                }
                
                switch self?.listIdentifier {
                case "followers":
                    guard let user = self?.user else { return }
                    self?.userListNavigationItem.title = "Followers"
                    self?.getFollowers(userID: user.id, completion: { [weak self] users in
                        DispatchQueue.main.async {
                            self?.users = users
                            self?.userListTableView.reloadData()
                            Spinner.stop()
                        }
                    })
                case "following":
                    guard let user = self?.user else { return }
                    self?.userListNavigationItem.title = "Following"
                    self?.getFollowingUsers(userID: user.id, completion: { [weak self] users in
                        DispatchQueue.main.async {
                            self?.users = users
                            self?.userListTableView.reloadData()
                            Spinner.stop()
                        }
                    })
                case "likes":
                    guard let post = self?.post else { return }
                    self?.userListNavigationItem.title = "Likes"
                    self?.getLikesForPost(postID: post.id, completion: { [weak self] users in
                        DispatchQueue.main.async {
                            self?.users = users
                            self?.userListTableView.reloadData()
                            Spinner.stop()
                        }
                    })
                default:
                    print("List identifier error")
                    Spinner.stop()
                    AlertController.showLocalError()
                }
                    
                self?.userListTableView.rowHeight = UITableView.automaticDimension
                self?.userListTableView.estimatedRowHeight = 45.0
                    
                self?.userListTableView.register(UINib(nibName: String(describing: UserListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: UserListCell.self))
                    
                self?.userListTableView.delegate = self
                self?.userListTableView.dataSource = self
            }
            
        })

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
    
    private func getFollowers(userID: String, completion: @escaping ([User]) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            AlertController.showError()
         return
        }
        let userID = userID
        
        networkService.getFollowersRequest(token: token, userID: userID, completion: { result in
            switch result {
            case .success(let followers):
                completion(followers)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
    private func getFollowingUsers(userID: String, completion: @escaping ([User]) -> ()) {
        guard let token = SecureStorableService.safeReadToken() else {
            print("Cannot read token from keychain")
            AlertController.showError()
         return
        }
        let userID = userID
        
        networkService.getFollowingUsersRequest(token: token, userID: userID, completion: { result in
            switch result {
            case .success(let followingUsers):
                completion(followingUsers)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
    private func getLikesForPost(postID: String, completion: @escaping ([User]) -> ()) {
     guard let token = SecureStorableService.safeReadToken() else {
         print("Cannot read token from keychain")
         AlertController.showError()
         return
     }
        let postID = postID
        
        networkService.getLikesForPostRequest(token: token, postID: postID, completion: { result in
            switch result {
            case .success(let usersLikedPost):
                completion(usersLikedPost)
            case .failure(let error):
                AlertController.showError(for: error)
            }
        })
    }
    
}
