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
    func didPressLikeButton(_ postID: Int, _ currentButtonTitle: String, _ sender: PostTableViewCell)
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
        postCellDelegate?.didPressDeleteButton(sender.tag)
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if let currentButtonTitle = likeButton.currentTitle {
            postCellDelegate?.didPressLikeButton(sender.tag, currentButtonTitle, self)
        }
        
    }
    
}
