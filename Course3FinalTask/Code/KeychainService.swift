//
//  KeychainService.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 02.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
//
// MARK: - UserCredentials
//
struct UserCredentials: Codable {
    var account: String
    var password: String
    var token: String
}
//
// MARK: - Keychain Service
//

/// Stores user password for Github server
class KeychainService {
    
    static let server = "http://localhost:8080"
    
    func saveToken(account: String, token: String) -> Bool {
        let account = account
        let token = token.data(using: String.Encoding.utf8)!
        
        if readToken(server: KeychainService.server) != nil {
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = token as AnyObject
            
            
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: account,
                                        kSecAttrServer as String: KeychainService.server,
                                        kSecValueData as String: token]
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            return status == noErr
        }
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: KeychainService.server,
                                    kSecValueData as String: token]
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == noErr
    }
    
    
    func readToken(server: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
       
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
        
        if status != noErr {
            return nil
        }
        
        guard let item = queryResult as? [String : AnyObject],
            let tokenData = item[kSecValueData as String] as? Data,
            let token = String(data: tokenData, encoding: .utf8) else {
            //let account = item[kSecAttrAccount as String] as? String else {
                return nil
        }
        return token
    }
    
    func deleteToken(server: String) -> Bool {
        let item: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: server]
        //kSecAttrAccount as String: account]
        let status = SecItemDelete(item as CFDictionary)
        return status == noErr
    }
    
}
