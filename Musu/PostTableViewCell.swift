//
//  PostTableViewCell.swift
//  Musu
//
//  Created by Richard Zarth on 5/2/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

protocol PostCellDelegate : class {
    func didPressDeleteButton(_ postID: Int)
}

class PostTableViewCell: UITableViewCell {
    
    weak var postCellDelegate: PostCellDelegate?
    
    //MARK: Properties
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Actions
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        print("Delete button pressed")
        postCellDelegate?.didPressDeleteButton(sender.tag)
    }
    
    @IBAction func likeOrUnlike(_ sender: UIButton) {
        // Get the postID from the button's tag
        let postID = sender.tag
        
        var apiFunctionName: String
        var newButtonTitle: String
        
        if likeButton.currentTitle == "Like" {
            // Unlike the post...
            apiFunctionName = "likePost"
            newButtonTitle = "Unlike"
        } else {
            // Like the post...
            apiFunctionName = "unlikePost"
            newButtonTitle = "Like"
        }
        
        let jsonPayload = [
            "function": apiFunctionName,
            "userID": getUserID(),
            "token": getToken(),
            "postID": String(postID)
        ]
        
        callAPI(withJSON: jsonPayload) { (jsonResponse) in
            if let success = jsonResponse["success"] as? Int {
                if (success == 1) {
                    DispatchQueue.main.async {
                        self.likeButton.setTitle(newButtonTitle, for: .normal)
                    }
                } else {
                    print("Failed to like/unlike post: \(String(describing: jsonResponse["error"]))")
                    return
                }
            }
        }
    }
    
}
