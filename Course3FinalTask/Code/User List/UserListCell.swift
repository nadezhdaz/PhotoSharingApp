//
//  UserListCell.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

class UserListCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    
    func setUser(_ user: User) {
        avatarImageView.image = user.avatar
        fullnameLabel.text = user.fullName
    }
}
