//
//  SecureNetworkHandler.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 11.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class SecureNetworkHandler: UIViewController {//}, SecureStorable {
    
    //typealias Data = <#type#>
    
    
    var networkService = NetworkService()
    var keychainService = KeychainService()
   
    func login(login: String, password: String, completion: @escaping () -> Void) {
       networkService.signInRequest(login: login, password: password, completion: { [weak self] token, errorMessage in
           if let newToken = token {
            self?.keychainService.saveToken(account: login, token: newToken)
            print("token saved")
           }
           else if let message = errorMessage  {
            AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
        }
           
       })
       
   }
   
   func logout() {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           return
       }
       networkService.signOutRequest(token: token, completion: { [weak self] errorMessage in
           if let message = errorMessage {
            self?.keychainService.deleteToken(server: KeychainService.server)
            AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
           }
           
       })
   }
   
   
    func checkToken(completion: @escaping (Bool) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
    
    networkService.checkTokenRequest(token: token, completion: { [weak self] checkResult, errorMessage in
           if checkResult {
            completion(true)
           }
           else if let message = errorMessage {
            AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
           }
           
       })
   }
   
   func getCurrentUserInfo(completion: @escaping (User) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
       //var user: User?
       
       networkService.currentUserInfoRequest(token: token, completion: { [weak self] currentUser, errorMessage in
           if let user = currentUser {
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
   
   func getUserInfo(userID: String, completion: @escaping (User) -> ()) {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           AlertController.showError()
        return
       }
       let userID = userID
       //var user: User?
       
       networkService.userInfoRequest(token: token, userID: userID, completion: { [weak self] user, errorMessage in
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
   
   func followUser(userID: String, completion: @escaping (User) -> ()) {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           AlertController.showError()
        return
       }
       let userID = userID
       //var user: User?
       
       networkService.followUserRequest(token: token, userID: userID, completion: { [weak self] user, errorMessage in
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
   
   func unfollowUser(userID: String, completion: @escaping (User) -> ()) {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           AlertController.showError()
        return
       }
       let userID = userID
       //var user: User?
       
       networkService.followUserRequest(token: token, userID: userID, completion: { [weak self] user, errorMessage in
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
   
   func getFollowers(userID: String, completion: @escaping ([User]) -> ()) {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           AlertController.showError()
        return
       }
       let userID = userID
       //var followers: [User?]
       
       networkService.getFollowersRequest(token: token, userID: userID, completion: { [weak self] users, errorMessage in
           if let followers = users {
            completion(followers) //users
           }
           else if let message = errorMessage {
           AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
               }
       })
   }
   
   func getFollowingUsers(userID: String, completion: @escaping ([User]) -> ()) {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           AlertController.showError()
        return
       }
       let userID = userID
       //var followingUsers: [User?]
       
       networkService.getFollowingUsersRequest(token: token, userID: userID, completion: { [weak self] users, errorMessage in
           if let followingUsers = users {
               completion(followingUsers) //users
           }
           else if let message = errorMessage {
           AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
               }
       })
   }
   
   func getPostsOfUser(userID: String, completion: @escaping ([Post]) -> ()) {
       guard let token = keychainService.readToken(server: KeychainService.server) else {
           print("Cannot read token from keychain")
           AlertController.showError()
        return
       }
       let userID = userID
       //var postsOfUser: [Post?]
       
       networkService.getPostsOfUserRequest(token: token, userID: userID, completion: { [weak self] posts, errorMessage in
           if let postsOfUser = posts {
               completion(postsOfUser) //posts
           }
           else if let message = errorMessage {
           AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
               }
       })
   }
   
   func getFeed(completion: @escaping ([Post]) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
          //var feed: [Post?]
          
          networkService.getFeedRequest(token: token, completion: { [weak self] posts, errorMessage in
              if let feed = posts {
                  completion(feed) //posts
              }
              else if let message = errorMessage {
              AlertController.showError(with: message)
              }
              else {
                AlertController.showError()
                  }
          })
      }
   
   func getPost(postID: String, completion: @escaping (Post) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
       let postID = postID
       //var post: Post?
       
       networkService.getPostRequest(token: token, postID: postID, completion: { [weak self] receivedPost, errorMessage in
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
   
   func likePost(postID: String, completion: @escaping (Post) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
       let postID = postID
       //var post: Post?
       
       networkService.likePostRequest(token: token, postID: postID, completion: { [weak self] likedPost, errorMessage in
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
   
   func unlikePost(postID: String, completion: @escaping (Post) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
       let postID = postID
       //var post: Post?
       
       networkService.unlikePostRequest(token: token, postID: postID, completion: { [weak self] unlikedPost, errorMessage in
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
   
   func getLikesForPost(postID: String, completion: @escaping ([User]) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
       let postID = postID
       //var users: [User?]
       
       networkService.getLikesForPostRequest(token: token, postID: postID, completion: { [weak self] usersLikedPost, errorMessage in
           if let users = usersLikedPost {
               completion(users)
           }
           else if let message = errorMessage {
           AlertController.showError(with: message)
           }
           else {
            AlertController.showError()
               }
       })
   }
   
   func createPost(image: UIImage, description: String, completion: @escaping (Post) -> ()) {
    guard let token = keychainService.readToken(server: KeychainService.server) else {
        print("Cannot read token from keychain")
        AlertController.showError()
        return
    }
       let image = image
       let description = description
       //var post: Post?
       
       networkService.createPostRequest(token: token, image: image, description: description, completion: { [weak self] createdPost, errorMessage in
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
   }}
