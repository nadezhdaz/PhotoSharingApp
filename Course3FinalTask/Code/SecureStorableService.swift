//
//  SecureStorableService.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 10.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

/*protocol SecureStorable: class {
    //associatedtype Data
    
    var networkService: NetworkService() { get }
    var keychainService: KeychainService()
    
    func login(login: String, password: String)
    func logout()
    func checkToken() -> String?
    func getCurrentUserInfo() -> User?
    func getUserInfo() -> User?
    func followUser(userID: String) -> User?
    func unfollowUser(userID: String) -> User?
    func getFollowers(userID: String) -> [User?]
    func getFollowingUsers(userID: String) -> [User?]
    func getPostsOfUser(userID: String) -> [Post?]
    func getFeed() -> [Post?]
    func getPost(postID: String) -> Post?
    func likePost(postID: String) -> Post?
    func unlikePost(postID: String) -> Post?
    func getLikesForPost(postID: String) -> [User?]
    func createPost(image: UIImage, description: String) -> Post?
}

extension SecureStorable {
    //var networkService = NetworkService()
    //var keychainService = KeychainService()
    
    func login(login: String, password: String) {
        networkService.signInRequest(login: login, password: password, completion: { [weak self] token, errorMessage in
            if let token = token {
                do {
                keychainService.saveToken(account: login, token: token)
                }
                catch {
                    debugPrint(error)
                }
            }
            else if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
            }
            
        })
        
    }
    
    func logout() {
        guard let token = keychainService.readToken(server: KeychainService.server) else {
            print("Cannot read token from keychain")
            return
        }
        networkService.signOutRequest(token: token, completion: { [weak self] errorMessage in
            if errorMessage != nil {
                keychainService.deleteToken(server: KeychainService.server)
                showError(with: errorMessage)
            }
            else {
                showError()
            }
            
        })
    }
    
    
    func checkToken() -> String? {
        guard let token = keychainService.readToken(server: KeychainService.server) else {
            print("Cannot read token from keychain")
            return
        }
        networkService.checkTokenRequest(token: token, completion: { [weak self] checkResult, errorMessage in
            if checkResult {
                return token
            }
            else if errorMessage != nil {
                showError(with: errorMessage)
                return nil
            }
            else {
                showError()
                return nil
            }
            
        })
    }
    
    func getCurrentUserInfo() -> User? {
        let token = checkToken()
        var user: User?
        
        networkService.currentUserInfoRequest(token: token, completion: { [weak self] currentUser, errorMessage in
            if user = currentUser {
                return user
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
        
    }
    
    func getUserInfo(userID: String) -> User? {
        let token = checkToken()
        let userID = userID
        var user: User?
        
        networkService.userInfoRequest(token: token, userID: userID, completion: { [weak self] user, errorMessage in
            if user = user {
                return user
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func followUser(userID: String) -> User? {
        let token = checkToken()
        let userID = userID
        var user: User?
        
        networkService.followUserRequest(token: token, userID: userID, completion: { [weak self] user, errorMessage in
            if user = user {
                return user
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func unfollowUser(userID: String) -> User? {
        let token = checkToken()
        let userID = userID
        var user: User?
        
        networkService.followUserRequest(token: token, userID: userID, completion: { [weak self] user, errorMessage in
            if user = user {
                return user
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func getFollowers(userID: String) -> [User?] {
        let token = checkToken()
        let userID = userID
        var followers: [User?]
        
        networkService.getFollowersRequest(token: token, userID: userID, completion: { [weak self] users, errorMessage in
            if followers = users {
                return followers //users
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func getFollowingUsers(userID: String) -> [User?] {
        let token = checkToken()
        let userID = userID
        var followingUsers: [User?]
        
        networkService.getFollowingUsersRequest(token: token, userID: userID, completion: { [weak self] users, errorMessage in
            if followingUsers = users {
                return followingUsers //users
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func getPostsOfUser(userID: String) -> [Post?] {
        let token = checkToken()
        let userID = userID
        var postsOfUser: [Post?]
        
        networkService.getPostsOfUserRequest(token: token, userID: userID, completion: { [weak self] posts, errorMessage in
            if postsOfUser = posts {
                return postsOfUser //posts
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func getFeed() -> [Post?] {
           let token = checkToken()
           var feed: [Post?]
           
           networkService.getFeedRequest(token: token, completion: { [weak self] posts, errorMessage in
               if feed = posts {
                   return feed //posts
               }
               if errorMessage != nil {
                   showError(with: errorMessage)
               }
               else {
                   showError()
                   }
           })
       }
    
    func getPost(postID: String) -> Post? {
        let token = checkToken()
        let postID = postID
        var post: Post?
        
        networkService.getPostRequest(token: token, postID: postID, completion: { [weak self] receivedPost, errorMessage in
            if post = receivedPost {
                return post
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func likePost(postID: String) -> Post? {
        let token = checkToken()
        let postID = postID
        var post: Post?
        
        networkService.likePostRequest(token: token, postID: postID, completion: { [weak self] likedPost, errorMessage in
            if post = likedPost {
                return post
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func unlikePost(postID: String) -> Post? {
        let token = checkToken()
        let postID = postID
        var post: Post?
        
        networkService.unlikePostRequest(token: token, postID: postID, completion: { [weak self] unlikedPost, errorMessage in
            if post = unlikedPost {
                return post
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func getLikesForPost(postID: String) -> [User?] {
        let token = checkToken()
        let postID = postID
        var users: [User?]
        
        networkService.getLikesForPostRequest(token: token, postID: postID, completion: { [weak self] usersLikedPost, errorMessage in
            if users = usersLikedPost {
                return users
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
    func createPost(image: UIImage, description: String) -> Post? {
        let token = checkToken()
        let image = image
        let description = description
        var post: Post?
        
        networkService.createPostRequest(token: token, image: image, description: description, completion: { [weak self] createdPost, errorMessage in
            if post = createdPost {
                return post
            }
            if errorMessage != nil {
                showError(with: errorMessage)
            }
            else {
                showError()
                }
        })
    }
    
}*/

