//
//  HeaderCollectionViewCell.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class HeaderCollectionViewCell: UICollectionReusableView {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel! {
        didSet {
            let followersTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(followersTapHandler(recognizer:)))
            followersLabel.addGestureRecognizer(followersTapRecognizer)
        }
    }
    @IBOutlet weak var followingLabel: UILabel! {
        didSet {
            let followingTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(followingTapHandler(recognizer:)))
            followingLabel.addGestureRecognizer(followingTapRecognizer)
        }
    }
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBAction func followButtonPressed(_ sender: Any) {
        followButtonTapHandler?()
    }
    
    var authorID = ""
    var followButtonTapHandler: (() -> Void)?
    var followersLabelTapHandler: (() -> Void)?
    var followingLabelTapHandler: (() -> Void)?
       
    
    public func setHeader(_ user: User, _ isCurrentUser: Bool)
    {
        avatarImageView.kf.setImage(with: user.avatar)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        fullnameLabel.text = user.fullName
        fullnameLabel.sizeToFit()
        followersLabel.text = "Followers: \(user.followedByCount)"
        followersLabel.sizeToFit()
        followingLabel.text = "Following: \(user.followsCount)"
        followingLabel.sizeToFit()
        authorID = user.id
        if isCurrentUser {
            followButton.isHidden = true
        }
        if user.currentUserFollowsThisUser {
            followButton.setTitle("Unfollow", for: .normal)
        }
    }
    
    public func updateFollows(_ user: User) {
        followersLabel.text = "Followers: \(user.followedByCount)"
        followersLabel.sizeToFit()
        followButton.setTitle((user.currentUserFollowsThisUser ? "Unfollow" :"Follow"), for: .normal)
    }
    
    @objc private func followersTapHandler(recognizer: UITapGestureRecognizer) {
        followersLabelTapHandler?()
    }
    
    @objc private func followingTapHandler(recognizer: UITapGestureRecognizer) {
        followingLabelTapHandler?()
    }
}
