//
//  PostDetailViewController.swift
//  Musu
//
//  Created by Richard Zarth on 5/6/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var post: Post?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let post = post {
            usernameLabel.text = post.username
            imageView.image = post.image
            bodyTextLabel.text = post.bodyText
            tagsLabel.text = post.tagsToString()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
