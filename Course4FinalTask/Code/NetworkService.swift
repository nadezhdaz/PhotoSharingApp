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

enum NetworkError: Error {
    case notFound
    case badRequest
    case notAcceptable
    case transferError
    case unprocessable
}

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
    var author: String?
    var description: String
    var image: URL
    var createdTime: String
    var currentUserLikesThisPost: Bool
    var likedByCount: Int
    var authorUsername: String
    var authorAvatar: URL
}

struct Token: Codable {
    var token: String
}

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
    // MARK: - Public Methods
    //
    
    func signInRequest(login: String, password: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        let userCredentials = ["login": login, "password": password]
        
        guard let request = urlRequestWith(token: nil, path: "/signin", httpMethod: "POST", json: userCredentials) else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 422 {
                completion(.failure(.unprocessable))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let token = self.parseTokenData(data)?.token else { return }
                completion(.success(token))
            }
            
        }
        
        task.resume()
    }
    
    func signOutRequest(token: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let token = token
        
        guard let request = urlRequestWith(token: token, path: "/signout", httpMethod: "POST") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                completion(.success(true))
            }
            
        }
        
        task.resume()
    }
    
    func checkTokenRequest(token: String, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        let token = token
        
        guard let request = urlRequestWith(token: token, path: "/checkToken", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Token is valid")
                completion(.success(true))
            }
            
        }
        
        task.resume()
    }
    
    func currentUserInfoRequest(token: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let token = token
        
        guard let request = urlRequestWith(token: token, path: "/users/me", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let user = self.parseUserData(data) else { return }
                completion(.success(user))
            }
            
        }
        
        task.resume()
    }
    
    func userInfoRequest(token: String, userID: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let token = token
        let id = userID
        
        guard let request = urlRequestWith(token: token, path: "/users/\(id)", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
                if let response = response as? HTTPURLResponse,
                    response.statusCode == 400 {
                    completion(.failure(.badRequest))
                } else if let response = response as? HTTPURLResponse,
                    response.statusCode == 404 {
                    completion(.failure(.notFound))
                } else if let response = response as? HTTPURLResponse,
                    response.statusCode != 200 {
                    completion(.failure(.transferError))
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    guard let user = self.parseUserData(data) else { return }
                    completion(.success(user))
            }
            
        }
        
        task.resume()
    }
    
    func followUserRequest(token: String, userID: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let token = token
        let id = ["userID": userID]
        
        guard let request = urlRequestWith(token: token, path: "/users/follow", httpMethod: "GET", json: id) else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 406 {
                completion(.failure(.notAcceptable))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let user = self.parseUserData(data) else { return }
                completion(.success(user))
            }
            
        }
        
        task.resume()
    }
    
    func unfollowUserRequest(token: String, userID: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let token = token
        let id = ["userID": userID]
        
        guard let request = urlRequestWith(token: token, path: "/users/unfollow", httpMethod: "GET", json: id) else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 406 {
                completion(.failure(.notAcceptable))
                
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
            response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let user = self.parseUserData(data) else { return }
                completion(.success(user))
            }
            
        }
        
        task.resume()
    }
    
    func getFollowersRequest(token: String, userID: String, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        let token = token
        let id = userID
        
        guard let request = urlRequestWith(token: token, path: "/users/\(id)/followers", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let users = self.parseUsersData(data) else { return }
                completion(.success(users))
            }
            
        }
        
        task.resume()
    }
    
    func getFollowingUsersRequest(token: String, userID: String, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        let token = token
        let id = userID
        
        guard let request = urlRequestWith(token: token, path: "/users/\(id)/following", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let users = self.parseUsersData(data) else { return }
                completion(.success(users))
            }
            
        }
        
        task.resume()
    }
    
    func getPostsOfUserRequest(token: String, userID: String, completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        let token = token
        let id = userID
        
        guard let request = urlRequestWith(token: token, path: "/users/\(id)/posts", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let posts = self.parsePostsData(data) else { return }
                completion(.success(posts))
            }
            
        }
        
        task.resume()
    }
    
    func getFeedRequest(token: String, completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        let token = token
        
        guard let request = urlRequestWith(token: token, path: "/posts/feed", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let posts = self.parsePostsData(data) else { return }
                completion(.success(posts))
            }
                        
        }
        
        task.resume()
    }
    
    func getPostRequest(token: String, postID: String, completion: @escaping (Result<Post, NetworkError>) -> Void) {
        let token = token
        let id = postID
        
        guard let request = urlRequestWith(token: token, path: "/posts/\(id)", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let post = self.parsePostData(data) else { return }
                completion(.success(post))
            }
            
        }
        
        task.resume()
    }
    
    func likePostRequest(token: String, postID: String, completion: @escaping (Result<Post, NetworkError>) -> Void) {
        let token = token
        let id = ["postID":postID]
        
        guard let request = urlRequestWith(token: token, path: "/posts/like", httpMethod: "POST", json: id) else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let post = self.parsePostData(data) else { return }
                completion(.success(post))
            }
            
        }
        
        task.resume()
    }
    
    func unlikePostRequest(token: String, postID: String, completion: @escaping (Result<Post, NetworkError>) -> Void) {
        let token = token
        let id = ["postID":postID]
        
        guard let request = urlRequestWith(token: token, path: "/posts/unlike", httpMethod: "POST", json: id) else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let post = self.parsePostData(data) else { return }
                completion(.success(post))
            }
            
        }
        
        task.resume()
    }
    
    func getLikesForPostRequest(token: String, postID: String, completion: @escaping (Result<[User], NetworkError>) -> Void) {
        let token = token
        let id = postID
        
        guard let request = urlRequestWith(token: token, path: "/posts/\(id)/likes", httpMethod: "GET") else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 404 {
                completion(.failure(.notFound))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let users = self.parseUsersData(data) else { return }
                completion(.success(users))
            }
            
        }
        
        task.resume()
    }
    
    func createPostRequest(token: String, image: UIImage, description: String, completion: @escaping (Result<Post, NetworkError>) -> Void) {
        let token = token
        let image = image
        let description = description
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        let base64ImageString = imageData.base64EncodedString()
        let postInformation = ["image": base64ImageString, "description": description]
        
        guard let request = urlRequestWith(token: token, path: "/posts/create", httpMethod: "POST", json: postInformation) else { return }
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 400 {
                completion(.failure(.badRequest))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.transferError))
            } else if
                let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                guard let post = self.parsePostData(data) else { return }
                completion(.success(post))
            }
            
        }
        
        task.resume()
    }
    
    //
    // MARK: - Private Methods
    //
    
    private func urlRequestWith(token: String?, path: String, httpMethod: String, json: [String : String]? = nil) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = path
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        if let token = token {
            request.setValue(token, forHTTPHeaderField: "token")
        }
        
        if httpMethod == "POST", let json = json {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return request
    }
    
    private func parseTokenData(_ data: Data) -> Token? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let token = try decoder.decode(Token.self, from: data)
            return token
          } catch {
            debugPrint(error)
            print("JSONDecoder error: \(error.localizedDescription)\n")
            return nil
        }
    }
    
    private func parseUserData(_ data: Data) -> User? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let user = try decoder.decode(User.self, from: data)
            return user
          } catch {
            debugPrint(error)
            print("JSONDecoder error: \(error.localizedDescription)\n")
            return nil
        }
    }
    
    private func parseUsersData(_ data: Data) -> [User]? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let users = try decoder.decode([User].self, from: data)
            return users
          } catch {
            debugPrint(error)
            print("JSONDecoder error: \(error.localizedDescription)\n")
            return nil
        }
    }
    
    private func parsePostData(_ data: Data) -> Post? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let post = try decoder.decode(Post.self, from: data)
            return post
          } catch {
            debugPrint(error)
            print("JSONDecoder error: \(error.localizedDescription)\n")
            return nil
        }
    }
    
    private func parsePostsData(_ data: Data) -> [Post]? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let posts = try decoder.decode([Post].self, from: data)
            return posts
          } catch {
            debugPrint(error)
            print("JSONDecoder error: \(error.localizedDescription)\n")
            return nil
        }
    }

}
