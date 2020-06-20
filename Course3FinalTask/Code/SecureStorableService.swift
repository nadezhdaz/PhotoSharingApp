//
//  SecureStorableService.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 10.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class SecureStorableService {
    
    static let networkService = NetworkService()
    static let keychainService = KeychainService()
    
    static func safeSaveToken(account: String, token: String) {
        let account = account
        let token = token        
        keychainService.saveToken(account: account, token: token)
    }
    
    static func safeReadToken() -> String? {
        guard let token = keychainService.readToken(server: KeychainService.server) else {
            print("Cannot read token from keychain")
            return nil
        }
        return token
    }
}

protocol SecureStorable: class {
    var networkService: NetworkService { get }
    var keychainService: KeychainService { get }
}

extension SecureStorable {
    
    func saveToken(account: String, token: String) {
        let account = account
        let token = token
        keychainService.saveToken(account: account, token: token)
    }
    
    func readToken() -> String? {
        guard let token = keychainService.readToken(server: KeychainService.server) else {
            print("Cannot read token from keychain")
            return nil
        }
        return token
    }
}
