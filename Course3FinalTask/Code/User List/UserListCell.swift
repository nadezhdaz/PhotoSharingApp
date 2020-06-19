//
//  UserListCell.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class UserListCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    
    func setUser(_ user: User) {
        avatarImageView.kf.setImage(with: user.avatar)
        fullnameLabel.text = user.fullName
    }
}
