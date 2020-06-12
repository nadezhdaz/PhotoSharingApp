//
//  SecureNetworkHandler.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 11.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class SecureNetworkHandler: SecureStorable {
    
    var networkService: NetworkService
    var keychainService: KeychainService
    
    /* func login(login: String, password: String) {
        
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
    }*/
}
