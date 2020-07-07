//
//  UserDataProvider.swift
//  Course2FinalTask
//
//  Created by Nadezhda Zenkova on 05/11/2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import DataProvider

class UserDataProvider: UsersDataProviderProtocol {
    func currentUser() -> User {
        return DataProviders.shared.usersDataProvider.currentUser()
    }
    
    func user(with userID: User.Identifier) -> User? {
        <#code#>
    }
    
    func follow(_ userIDToFollow: User.Identifier) -> Bool {
        <#code#>
    }
    
    func unfollow(_ userIDToUnfollow: User.Identifier) -> Bool {
        <#code#>
    }
    
    func usersFollowingUser(with userID: User.Identifier) -> [User]? {
        <#code#>
    }
    
    func usersFollowedByUser(with userID: User.Identifier) -> [User]? {
        <#code#>
    }
    

}

