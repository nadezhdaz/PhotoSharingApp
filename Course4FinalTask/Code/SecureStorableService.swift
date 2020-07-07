//
//  SecureStorableService.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 10.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class SecureStorableService {
    
    static func safeSaveToken(account: String, token: String) {
        let keychainService = KeychainService()
        let account = account
        let token = token
        keychainService.saveToken(account: account, token: token)
    }
    
    static func safeReadToken() -> String? {
        let keychainService = KeychainService()
        let server = KeychainService.server
        guard let token = keychainService.readToken(server: server) else {
            print("Cannot read token from keychain")
            return nil
        }
        return token
    }
    
    static func safeDeleteToken() {
        let keychainService = KeychainService()
        let server = KeychainService.server
        keychainService.deleteToken(server: server)
        
    }
}
