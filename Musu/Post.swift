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

    init() {
        username = ""
        bodyText = ""
        postID = 0
        userID = 0
        image = nil
        tags = []
    }
    
    func testPost() {
        username = "TESTUSER"
        bodyText = "Test body text; test body text; test body text."
        postID = 1;
        userID = 1;
        image = UIImage(named: "placeholder_image")
        tags = ["TAG1", "TAG2", "TAG3"]
    }
}
