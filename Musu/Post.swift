//
//  Post.swift
//  Musu
//
//  Created by Richard Zarth on 4/23/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

class Post {

    //MARK: Properties
    
    var username: String
    var bodyText: String
    var postID: Int
    var userID: Int
    var image: UIImage?
    var tags: Array<String>

    init?(username: String, bodyText: String, postID: Int, userID: Int, image: UIImage?, tags: Array<String>) {
        self.username = username
        self.bodyText = bodyText
        self.postID = postID
        self.userID = userID
        self.image = image
        self.tags = tags
    }
    
    func tagsToString() -> String {
        return tags.description
        
        // perhaps a better implementation
        // return tags.joined(separator: ", ")
    }
}
