//  FeedTableViewCell.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            let usernameTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(feedToProfileTapHandler(recognizer:)))
            usernameLabel.addGestureRecognizer(usernameTapRecognizer)
        }
    }
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            let dateTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(feedToProfileTapHandler(recognizer:)))
            dateLabel.addGestureRecognizer(dateTapRecognizer)
        }
    }
    @IBOutlet weak var pictureImageView: UIImageView! {
        didSet {
            let pictureDoubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pictureDoubleTapHandler(recognizer:)))
            pictureDoubleTapRecognizer.numberOfTapsRequired = 2
            pictureImageView.addGestureRecognizer(pictureDoubleTapRecognizer)
        }
    }
    @IBOutlet weak var likesCounterLabel: UILabel! {
        didSet {
            let likesCounterTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(likesCounterTapHandler(recognizer:)))
            likesCounterLabel.addGestureRecognizer(likesCounterTapRecognizer)
        }
    }
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        likeButtonTapHandler?()
    }
    
    @IBAction func avatarButtonPressed(_ sender: Any) {
        profileTapHandler?()
    }
    
    let defaultTintColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
    var currentPost: Post?
    var postID = "" //: Post.id?
    var authorID = "" //: User.id = ""
    var likeButtonTapHandler: (() -> Void)?
    var profileTapHandler: (() -> Void)?
    var likesCounterTapHandler: (() -> Void)?
    
    public func setPost(_ post: Post) {
        currentPost = post
        postID = post.id
        authorID = post.author ?? ""
        avatarButton.kf.setImage(with: post.authorAvatar, for: .normal)
        usernameLabel.text = post.authorUsername
        dateLabel.text = postTime(post.createdTime)
        pictureImageView.kf.setImage(with: post.image)
        likesCounterLabel.text = "Likes: \(post.likedByCount)"
        likeButton.tintColor = post.currentUserLikesThisPost ? defaultTintColor : UIColor.lightGray
        postTextLabel.text = post.description
    }
    
    public func updateLikes(_ post: Post?) {
        guard let post = post else { return }
        if post.currentUserLikesThisPost {
            performBigLikeAnimation(view: bigLikeImageView)
        }
        likesCounterLabel.text = post.currentUserLikesThisPost ? "Likes: \(post.likedByCount - 1)" : "Likes: \(post.likedByCount + 1)"
        likeButton.tintColor = post.currentUserLikesThisPost ? UIColor.lightGray : defaultTintColor
    }
    
    private func postTime(_ time: String) -> String {
        let time = time
        let dateFormatterISO8601 = ISO8601DateFormatter()
        let dateFormatter = DateFormatter()
        dateFormatterISO8601.formatOptions = [ .withInternetDateTime ]
        let formattedTime = dateFormatterISO8601.date(from: time)!
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm:ss aaa"
        let postTime = dateFormatter.string(from: formattedTime)
        return postTime
    }
    
    private func performBigLikeAnimation(view: UIView) {
        view.alpha = 0
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveLinear], animations: {
            view.alpha = 1
        }) { completion in
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [.curveEaseOut], animations: {
                view.alpha = 0
            })  { completion in
            }
        }
    }
    
    @objc private func pictureDoubleTapHandler(recognizer: UITapGestureRecognizer) {
        likeButtonTapHandler?()
    }
    
    @objc private func feedToProfileTapHandler(recognizer: UITapGestureRecognizer) {
        profileTapHandler?()
    }
    
    @objc private func likesCounterTapHandler(recognizer: UITapGestureRecognizer) {
        likesCounterTapHandler?()
    }
    
}
