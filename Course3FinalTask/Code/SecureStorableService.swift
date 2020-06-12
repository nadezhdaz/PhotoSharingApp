//
//  SecureStorableService.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 10.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

protocol SecureStorable {
    associatedtype Data
    
    func get(completionHandler: (Result<Data>) -> Void)
    func login(login: String, password: String)
    func logout()
    func checkToken() -> String?
    func getCurrentUserInfo() -> UserInfo?
    func getUserInfo() -> UserInfo?
}

extension SecureStorable {
    var networkService = NetworkService()
    var keychainService = KeychainService()
    
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
    
    func getCurrentUserInfo() -> UserInfo? {
        let token = checkToken()
        var user: UserInfo?
        
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
    
    func getUserInfo() -> UserInfo? {
        let token = checkToken()
        var user: UserInfo?
        
        networkService.userInfoRequest(token: token, completion: { [weak self] user, errorMessage in
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
    
}

