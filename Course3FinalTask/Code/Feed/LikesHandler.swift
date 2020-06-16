//
//  LikesHandler.swift
//  Course3FinalTask
//
//  Created by Надежда Зенкова on 23/06/2019.
//  Copyright © 2019 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class LikesHandler: UIViewController {
    
    public func likeHandler(_ cell: FeedTableViewCell, _ table: UITableView) {
        
        let post = cell.currentPost
        
        var queue: DispatchQueue? = DispatchQueue(label: "com.myqueues.customQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global(qos: .userInteractive))
        
        if !(post!.currentUserLikesThisPost) {
            cell.bigLikeAnimation()
            DataProviders.shared.postsDataProvider.likePost(with: cell.postID, queue: self.queue, handler: { [weak self] incomingPost in
                guard let self = self else { return }
                if incomingPost != nil {
                    DispatchQueue.main.async {
                        cell.updateLikes(post)
                    }
                }
                else {
                    self.showError()
                }
            })
            
        } else {
            
            DataProviders.shared.postsDataProvider.unlikePost(with: cell.postID, queue: self.queue, handler: { [weak self] incomingPost in
                guard let self = self else { return }
                if incomingPost != nil {
                    DispatchQueue.main.async {
                        cell.updateLikes(post)
                    }
                }
                else {
                    self.showError()
                }
            })
            
        }
        DataProviders.shared.postsDataProvider.feed(queue: self.queue, handler: { [weak self] incomingPosts in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if incomingPosts != nil {
                    Posts.list = incomingPosts!
                    table.reloadData()
                    table.layoutIfNeeded()
                }
                else {
                    self.showError()
                }
            }
            
            
            
        })
}
}
