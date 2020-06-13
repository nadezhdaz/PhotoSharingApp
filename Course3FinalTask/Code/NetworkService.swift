//
//  NetworkService.swift
//  
//
//  Created by Надежда Зенкова on 31.05.2020.
//

import Foundation
import UIKit

//
// MARK: - Network Service
//

struct User: Codable {
    var id: String
    var username: String
    var fullName: String
    var avatar: URL
    var currentUserFollowsThisUser: Bool
    var currentUserIsFollowedByThisUser: Bool
    var followsCount: Int
    var followedByCount: Int
}

struct Post: Codable {
    var id: String
    var authorID: String
    var description: String
    var image: URL
    var createdTime: Int
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
    var authorUsername: String
    var authorAvatar: URL
}
/// Runs query data task
class NetworkService {
    //
    // MARK: - Constants
    //
    let defaultSession = URLSession(configuration: .default)
    let scheme = "http"
    let host = "localhost:8080"
    let hostPath = "http://localhost:8080"
    let currentUserInfoPath = "/users/me"
    let usersInfoPath = "/users"
    let postsInfoPath = "/posts"
    let jsonHeaders = [
        "Content-Type" : "application/json"
    ]
    //
    // MARK: - Variables And Properties
    //
    
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    
    
    //
    // MARK: - Type Alias
    //
    typealias JSONDictionary = [String: Any]
    typealias AuthorizationResult = (String, String) -> Void
    
    //
    // MARK: - Internal Methods
    //
    
    func signInRequest(login: String, password: String, completion: @escaping AuthorizationResult) {
        let login = login
        let password = password
        let loginString = "\(account):\(password)"
        var token: String?
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.queryItems = [
            URLQueryItem(name: "login", value: login),
            URLQueryItem(name: "password", value: password)
        ]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = jsonHeaders
        
        urlRequest.httpMethod = "POST"
        //urlRequest.httpBody = Data(query.utf8)
        
        /*let url = URL(string: hostPath)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "login", value: login),
            URLQueryItem(name: "password", value: password)
        ]

        let query = components.url!.query
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(query.utf8)*/
        
        //request.httpMethod = "POST"
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //let parameters = ["username": account, "password": password]
        
        //do {
        //    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        //} catch let error {
        //    print(error.localizedDescription)
        //}
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                 do {
                    let decoder = JSONDecoder()
                    //decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userToken = try decoder.decode(String, from: data)
                    token = userToken
                 } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                }
                completion(userToken, self?.errorMessage ?? "")
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 422 {
                self?.errorMessage += "\(response.statusCode) Inavalid login or password: " + error.localizedDescription + "\n"
                completion(self?.token, self?.errorMessage ?? "")
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(self?.token, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func signOutRequest(token: String, completion: @escaping (String) -> Void) {
        let token = token
        
        let url = URL(string: hostPath)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]

        //let query = components.url!.query
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        request.setValue(token, forHTTPHeaderField: "header")
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("User signed out")
                completion(self?.errorMessage ?? "")
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func checkTokenRequest(token: String, completion: @escaping (Bool, String) -> Void) {
        let token = token
        
        let url = URL(string: hostPath)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]

        //let query = components.url!.query
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        request.setValue(token, forHTTPHeaderField: "header")
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Token is valid")
                completion(true, self?.errorMessage ?? "")
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(false, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(false, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func currentUserInfoRequest(token: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        var user: User?
    
    //let url = URL(string: hostPath)!
    //var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

    //components.queryItems = [
    //    URLQueryItem(name: "token", value: token)
    //]

    //let query = components.url!.query
    
    //var request = URLRequest(url: url)
    //request.httpMethod = "GET"
    ////request.httpBody = Data(query.utf8)
    //request.setValue(token, forHTTPHeaderField: "header")
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = currentUserInfoPath
        //urlComponents.queryItems = [
        //    URLQueryItem(name: "login", value: login),
        //    URLQueryItem(name: "password", value: password)
        //]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(UserInfo.self, from: data)
                    user = userInfo
                    
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(user, self?.errorMessage ?? "")
                
            }
                
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(user, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func userInfoRequest(token: String, userID: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        let id = userID
        var user: User?
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(usersInfoPath)/\(id)"
        //urlComponents.queryItems = [
        //    URLQueryItem(name: "login", value: login),
        //    URLQueryItem(name: "password", value: password)
        //]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(UserInfo.self, from: data)
                    user = userInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(user, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    self?.errorMessage += "\(response.statusCode) User not found: " + error.localizedDescription + "\n"
                    completion(user, self?.errorMessage ?? "")
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(user, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func followUserRequest(token: String, userID: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        let id = userID
        var user: User?
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(usersInfoPath)/follow"
        urlComponents.queryItems = [
            URLQueryItem(name: "userID", value: id)
        ]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "POST"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(UserInfo.self, from: data)
                    user = userInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(user, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    self?.errorMessage += "\(response.statusCode) User not found: " + error.localizedDescription + "\n"
                    completion(user, self?.errorMessage ?? "")
            }
                else if let response = response as? HTTPURLResponse,
                    response.statusCode == 406 {
                        self?.errorMessage += "\(response.statusCode) Attempt to follow yourself: " + error.localizedDescription + "\n"
                        completion(user, self?.errorMessage ?? "")
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(user, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func unfollowUserRequest(token: String, userID: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        let id = userID
        var user: User?
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(usersInfoPath)/unfollow"
        urlComponents.queryItems = [
            URLQueryItem(name: "userID", value: id)
        ]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "POST"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(UserInfo.self, from: data)
                    user = userInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(user, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    self?.errorMessage += "\(response.statusCode) User not found: " + error.localizedDescription + "\n"
                    completion(user, self?.errorMessage ?? "")
            }
                else if let response = response as? HTTPURLResponse,
                    response.statusCode == 406 {
                        self?.errorMessage += "\(response.statusCode) Attempt to unfollow yourself: " + error.localizedDescription + "\n"
                        completion(user, self?.errorMessage ?? "")
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(user, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getFollowersRequest(token: String, userID: String, completion: @escaping ([User?], String?) -> Void) {
        let token = token
        let id = userID
        var followers: [User?]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(usersInfoPath)/\(id)/followers"
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let followersUserInfo = try decoder.decode([UserInfo].self, from: data)
                    followers = followersUserInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(followers, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    self?.errorMessage += "\(response.statusCode) User not found: " + error.localizedDescription + "\n"
                    completion(nil, self?.errorMessage ?? "")
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getFollowingUsersRequest(token: String, userID: String, completion: @escaping ([User?], String?) -> Void) {
        let token = token
        let id = userID
        var followingUsers: [User?]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(usersInfoPath)/\(id)/following"
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let followingUserInfo = try decoder.decode([UserInfo].self, from: data)
                    followingUsers = followingUserInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(followingUsers, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    self?.errorMessage += "\(response.statusCode) User not found: " + error.localizedDescription + "\n"
                    completion(nil, self?.errorMessage ?? "")
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getPostsOfUserRequest(token: String, userID: String, completion: @escaping ([Post?], String?) -> Void) {
        let token = token
        let id = userID
        var posts: [Post?]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(usersInfoPath)/\(id)/posts"
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let postsInfo = try decoder.decode([Post].self, from: data)//Array<Post>.self
                    posts = postsInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(posts, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    self?.errorMessage += "\(response.statusCode) User not found: " + error.localizedDescription + "\n"
                    completion(nil, self?.errorMessage ?? "")
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getFeedRequest(token: String, userID: String, completion: @escaping ([Post?], String?) -> Void) {
        let token = token
        let id = userID
        var posts: [Post?]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(postsInfoPath)/feed"
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let postsInfo = try decoder.decode([Post].self, from: data)//Array<Post>.self
                    posts = postsInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(posts, self?.errorMessage ?? "")
                
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getPostRequest(token: String, postID: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let id = postID
        var post: Post?
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(postsInfoPath)/\(id)"
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let postInfo = try decoder.decode(Post.self, from: data)
                    post = postInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(post, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                    response.statusCode == 404 {
                        self?.errorMessage += "\(response.statusCode) Post not found: " + error.localizedDescription + "\n"
                        completion(nil, self?.errorMessage ?? "")
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func likePostRequest(token: String, postID: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let id = postID
        var post: Post?
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(postsInfoPath)/like"
        urlComponents.queryItems = [
            URLQueryItem(name: "postID", value: id)
        ]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "POST"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let postInfo = try decoder.decode(Post.self, from: data)
                    post = postInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(posts, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                    response.statusCode == 404 {
                        self?.errorMessage += "\(response.statusCode) Post not found: " + error.localizedDescription + "\n"
                        completion(nil, self?.errorMessage ?? "")
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func unLikePostRequest(token: String, postID: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let id = postID
        var post: Post?
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(postsInfoPath)/unlike"
        urlComponents.queryItems = [
            URLQueryItem(name: "postID", value: id)
        ]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "POST"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let postInfo = try decoder.decode(Post.self, from: data)
                    post = postInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(posts, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                    response.statusCode == 404 {
                        self?.errorMessage += "\(response.statusCode) Post not found: " + error.localizedDescription + "\n"
                        completion(nil, self?.errorMessage ?? "")
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func getLikesForPostRequest(token: String, postID: String, completion: @escaping ([User?], String?) -> Void) {
        let token = token
        let id = postID
        var users: [User?]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(postsInfoPath)/\(id)/likes"
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "GET"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let usersInfo = try decoder.decode([UserInfo].self, from: data)
                    users = usersInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(users, self?.errorMessage ?? "")
                
            }
                else if let response = response as? HTTPURLResponse,
                    response.statusCode == 404 {
                        self?.errorMessage += "\(response.statusCode) Post not found: " + error.localizedDescription + "\n"
                        completion(nil, self?.errorMessage ?? "")
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    func createPostRequest(token: String, image: UIImage, description: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let image = image
        let description = description
        var post: Post?
        
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        let base64ImageString = imageData.base64EncodedString()
        //let base64ImageString = imageData.base64EncodedString(options: .lineLength64Characters)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "\(postsInfoPath)/create"
        urlComponents.queryItems = [
            URLQueryItem(name: "image", value: base64ImageString),
            URLQueryItem(name: "description", value: description)
        ]
        
            guard let url = urlComponents.url else {
                return
            }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = token
        
        urlRequest.httpMethod = "POST"
        //urlRequest.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let postInfo = try decoder.decode(Post.self, from: data)
                    post = postInfo
                  } catch {
                    debugPrint(error)
                    errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
                    return
                    
                }
                completion(posts, self?.errorMessage ?? "")
                
            }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                self?.errorMessage += "\(response.statusCode) Bad request: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            } else {
                self?.errorMessage += "\(response.statusCode) Unknown error: " + error.localizedDescription + "\n"
                completion(nil, self?.errorMessage ?? "")
            }
            
        }
        
        task.resume()
    }
    
    
    
   /* func makeAuthorizationRequest(account: String, password: String, completion: @escaping AuthorizationResult) {
        let account = account
        let password = password
        let loginString = "\(account):\(password)"
        
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        let url = URL(string: hostPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters = ["username": account, "password": password]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let error = error {
                self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                self?.parseUserData(data)
                completion(self?.user, self?.errorMessage ?? "")
            }
            else {
                
            }
        }
        
        task.resume()
    }*/
    
    //
    // MARK: - Private Methods
    //
    
    private func parseUserData(_ data: Data) {
        user = nil
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let userToken = try decoder.decode(String, from: data)
            user = userInfo
        } catch {
            debugPrint(error)
            errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
            return
        }
        
    }
    
    private func parseUserInfo(_ data: Data) {
       // repositories = nil
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let userInfo = try decoder.decode(User.self, from: data)
            repositories = repositoriesInfo
        } catch {
            debugPrint(error)
            errorMessage += "JSONDecoder error: \(error.localizedDescription)\n"
            return
        }

    }
}
