//
//  PostTableViewCell.swift
//  Musu
//
//  Created by Richard Zarth on 5/2/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
