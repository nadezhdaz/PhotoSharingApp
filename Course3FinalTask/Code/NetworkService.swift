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
    var createdTime: Date//Int
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
    var authorUsername: String
    var authorAvatar: URL
}

struct Token: Codable {
    var token: String
}

/// Runs query data task
class NetworkService {
    //
    // MARK: - Constants
    //
    let defaultSession = URLSession(configuration: .default)
    let scheme = "http"
    let host = "localhost"
    let port = 8080
    let hostPath = "http://localhost:8080"
    let jsonHeaders = [
        "Content-Type" : "application/json"
    ]
    //
    // MARK: - Variables And Properties
    //
    
    var dataTask: URLSessionDataTask?
    //var errorMessage = ""
    
    //
    // MARK: - Type Alias
    //
    //typealias JSONDictionary = [String: Any]
    //typealias AuthorizationResult = (String?, String) -> Void
    
    //
    // MARK: - Internal Methods
    //
    

    func signInRequest(login: String, password: String, completion: @escaping (String?, String?) -> Void) {
        let userCredentials = ["login": login, "password": password]
        var token: Token?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/signin"
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userCredentials, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
            response.statusCode == 422 {
                errorMessage = "Unprocessable"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                 do {
                    let decoder = JSONDecoder()
                    token = try decoder.decode(Token.self, from: data)
                 } catch {
                    debugPrint(error)
                }
                completion(token?.token, nil)
            }
            
            let data = data
            let response = response as? HTTPURLResponse
            let error = error as? Error
            print(response?.statusCode)
            
        }
        
        task.resume()
    }
    
    func signOutRequest(token: String, completion: @escaping (String?) -> Void) {
        let token = token
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/signout"
        
        guard let url = urlComponents.url else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        //request.setValue(token, forHTTPHeaderField: "header")
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(errorMessage)
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(errorMessage)
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("User signed out")
                completion(nil)
            }
            
        }
        
        task.resume()
    }
    
    func checkTokenRequest(token: String, completion: @escaping (Bool, String?) -> Void) {
        let token = token
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/checkToken"
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        //request.setValue(token, forHTTPHeaderField: "header")
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(false, errorMessage)
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(false, errorMessage)
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Token is valid")
                completion(true, nil)
            }
            
        }
        
        task.resume()
    }
    
    func currentUserInfoRequest(token: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        var user: User?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/users/me"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
       guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(User.self, from: data)
                    user = userInfo
                    
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(user, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func userInfoRequest(token: String, userID: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        let id = userID
        var user: User?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/users/\(id)"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
                if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                    errorMessage = "Bad request"
                    completion(nil, errorMessage)
                } else if let response = response as? HTTPURLResponse,
                    response.statusCode == 404 {
                        errorMessage = "Not found"
                        completion(nil, errorMessage)
                } else if let response = response as? HTTPURLResponse,
                    response.statusCode != 200 {
                    errorMessage = "Transfer error"
                    completion(nil, errorMessage)
                } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(User.self, from: data)
                    user = userInfo
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(user, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func followUserRequest(token: String, userID: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        //let id = userID
        let id = ["userID": userID]
        var user: User?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/users/follow"
        urlComponents.queryItems = [
            //URLQueryItem(name: "userID", value: id),
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "POST"
        //request.httpBody = Data(query.utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: id, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
                    response.statusCode == 406 {
                        errorMessage = "Not acceptable"
                        completion(nil, errorMessage)
                }
            else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(User.self, from: data)
                    user = userInfo
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(user, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func unfollowUserRequest(token: String, userID: String, completion: @escaping (User?, String?) -> Void) {
        let token = token
        let id = userID
        var user: User?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = "users/unfollow"
        urlComponents.queryItems = [
            URLQueryItem(name: "userID", value: id),
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "POST"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
                    response.statusCode == 406 {
                        errorMessage = "Not acceptable"
                        completion(nil, errorMessage)
                
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let userInfo = try decoder.decode(User.self, from: data)
                    user = userInfo
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(user, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func getFollowersRequest(token: String, userID: String, completion: @escaping ([User]?, String?) -> Void) {
        let token = token
        let id = userID
        var followers: [User]?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/users/\(id)/followers"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let followersUserInfo = try decoder.decode([User].self, from: data)
                    followers = followersUserInfo
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(followers, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func getFollowingUsersRequest(token: String, userID: String, completion: @escaping ([User]?, String?) -> Void) {
        let token = token
        let id = userID
        var followingUsers: [User]?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "users/\(id)/following"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let followingUserInfo = try decoder.decode([User].self, from: data)
                    followingUsers = followingUserInfo
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(followingUsers, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func getPostsOfUserRequest(token: String, userID: String, completion: @escaping ([Post]?, String?) -> Void) {
        let token = token
        let id = userID
        var posts: [Post]?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "users/\(id)/posts"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
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
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(posts, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func getFeedRequest(token: String, completion: @escaping ([Post]?, String?) -> Void) {
        let token = token
        var posts: [Post]?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/posts/feed"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
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
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(posts, nil)
                
            }
                        
        }
        
        task.resume()
    }
    
    func getPostRequest(token: String, postID: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let id = postID
        var post: Post?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/posts/\(id)"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
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
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(post, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func likePostRequest(token: String, postID: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let id = postID
        var post: Post?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/posts/like"
        urlComponents.queryItems = [
            URLQueryItem(name: "postID", value: id),
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "POST"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
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
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(post, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func unlikePostRequest(token: String, postID: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let id = postID
        var post: Post?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "/posts/unlike"
        urlComponents.queryItems = [
            URLQueryItem(name: "postID", value: id),
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "POST"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
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
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(post, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func getLikesForPostRequest(token: String, postID: String, completion: @escaping ([User]?, String?) -> Void) {
        let token = token
        let id = postID
        var users: [User]?
        var errorMessage = ""
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "posts/\(id)/likes"
        urlComponents.queryItems = [
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "GET"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                    errorMessage = "Not found"
                    completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                  do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let usersInfo = try decoder.decode([User].self, from: data)
                    users = usersInfo
                  } catch {
                    debugPrint(error)
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(users, nil)
                
            }
            
        }
        
        task.resume()
    }
    
    func createPostRequest(token: String, image: UIImage, description: String, completion: @escaping (Post?, String?) -> Void) {
        let token = token
        let image = image
        let description = description
        var post: Post?
        var errorMessage = ""
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
            return
        }
        let base64ImageString = imageData.base64EncodedString()
        //let base64ImageString = imageData.base64EncodedString(options: .lineLength64Characters)
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "posts/create"
        urlComponents.queryItems = [
            URLQueryItem(name: "image", value: base64ImageString),
            URLQueryItem(name: "description", value: description),
            URLQueryItem(name: "header", value: token)
        ]
        
        guard let url = urlComponents.url else { return }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = token
        
        request.httpMethod = "POST"
        //request.httpBody = Data(query.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            if let response = response as? HTTPURLResponse,
            response.statusCode == 400 {
                errorMessage = "Bad request"
                completion(nil, errorMessage)
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                errorMessage = "Transfer error"
                completion(nil, errorMessage)
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
                    print("JSONDecoder error: \(error.localizedDescription)\n")
                    return
                    
                }
                completion(post, nil)
                
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
                print("DataTask error: " + error.localizedDescription + "\n")
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                self?.parseUserData(data)
                completion(self?.user, errorMessage)
            }
            else {
                
            }
        }
        
        task.resume()
    }
    
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
            print("JSONDecoder error: \(error.localizedDescription)\n")
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
            print("JSONDecoder error: \(error.localizedDescription)\n")
            return
        }

    }*/
}
