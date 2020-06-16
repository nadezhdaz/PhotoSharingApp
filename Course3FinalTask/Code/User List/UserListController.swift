//
//  UserListController.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class UserListController: UIViewController, UITableViewDelegate, UITableViewDataSource { //}, SecureStorable {
    
    @IBOutlet var userListTableView: UITableView!
    @IBOutlet weak var userListNavigationItem: UINavigationItem!
    
    var queue: DispatchQueue? = DispatchQueue(label: "com.myqueues.customQueue", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global(qos: .utility))
    var user: User?
    var post: Post?
    var users: [User] = []
    var userIDs: [User] = []
    var listIdentifier: String = ""
    var networkHandler = SecureNetworkHandler()

    
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
        
        DispatchQueue.main.async {
            if self.user == nil {
                self.networkHandler.getCurrentUserInfo(completion: { [weak self] user in
                    self?.user = user })
                }
            
            
            switch self.listIdentifier {
                case "followers":
                    self.userListNavigationItem.title = "Followers"
                    self.networkHandler.getFollowers(userID: self.user.id, completion: { [weak self] users in
                        self?.users = users
                    })
                    //users = getFollowers(userID: user?.id)
                    self.userListTableView.reloadData()
                    Spinner.stop()
                case "following":
                    self.userListNavigationItem.title = "Following"
                    self.networkHandler.getFollowingUsers(userID: self.user?.id, completion: { [weak self] users in
                        self?.users = users
                    })
                    //users = getFollowingUsers(userID: user?.id)
                    self.userListTableView.reloadData()
                    Spinner.stop()
                case "likes":
                    self.userListNavigationItem.title = "Likes"
                    self.networkHandler.getLikesForPost(userID: self.post?.id, completion: { [weak self] users in
                        self?.users = users
                    })
                    //users = getLikesForPost(postID: post?.id)
                    self.userListTableView.reloadData()
                    Spinner.stop()
                    
                default:
                    print("List identifier error")
                    self.showError()
                }
                
            self.userListTableView.rowHeight = UITableViewAutomaticDimension
            self.userListTableView.estimatedRowHeight = 45.0
                
            self.userListTableView.register(UINib(nibName: String(describing: UserListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: UserListCell.self))
                
            self.userListTableView.delegate = self
            self.userListTableView.dataSource = self
            }
        
     //   DataProviders.shared.usersDataProvider.currentUser(queue: self.queue, handler: { [weak self] currentUser in
     //       guard let self = self else { return }
     //       DispatchQueue.main.async {
     //           Spinner.start()
     //           if currentUser != nil {
     //               if self.user == nil {
     //                   self.user = currentUser!
     //               }
     //           }
     //           else {
     //               self.showError()
     //           }
     //
     //         switch self.listIdentifier {
     //         case "followers":
     //             self.userListNavigationItem.title = "Followers"
     //             DataProviders.shared.usersDataProvider.usersFollowingUser(with: self.user!.id, queue: self.queue, handler: { [weak self] incomingUsers in
     //                 guard let self = self else { return }
     //                 DispatchQueue.main.async {
     //                     if incomingUsers != nil {
     //                         self.users = incomingUsers!
     //                         self.userListTableView.reloadData()
     //                         Spinner.stop()
     //                     }
     //                     else {
     //                         self.showError()
     //                     }
     //                 }
     //             })
     //         case "following":
     //             self.userListNavigationItem.title = "Following"
     //             DataProviders.shared.usersDataProvider.usersFollowedByUser(with: self.user!.id, queue: self.queue, handler: { [weak self] incomingUsers in
     //                 guard let self = self else { return }
     //                 DispatchQueue.main.async {
     //                     if incomingUsers != nil {
     //                         self.users = incomingUsers!
     //                         self.userListTableView.reloadData()
     //                         Spinner.stop()
     //                     }
     //                     else {
     //                         self.showError()
     //                     }
     //                 }
     //             })
     //         case "likes":
     //             self.userListNavigationItem.title = "Likes"
     //             DataProviders.shared.postsDataProvider.usersLikedPost(with: self.post!.id, queue: self.queue, handler: { [weak self] incomingUsers in
     //                 guard let self = self else { return }
     //                 DispatchQueue.main.async {
     //                     if incomingUsers != nil {
     //                         self.users = incomingUsers!
     //                         self.userListTableView.reloadData()
     //                         Spinner.stop()
     //                     }
     //                     else {
     //                         self.showError()
     //                     }
     //                 }
     //             })
     //
     //         default:
     //             print("List identifier error")
     //             self.showError()
     //         }
     //
     //         self.userListTableView.rowHeight = UITableViewAutomaticDimension
     //         self.userListTableView.estimatedRowHeight = 45.0
     //
     //         self.userListTableView.register(UINib(nibName: String(describing: UserListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: UserListCell.self))
     //
     //         self.userListTableView.delegate = self
     //         self.userListTableView.dataSource = self
     //     }
      //  })

    }
}
