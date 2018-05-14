//
//  PostTableViewController.swift
//  Musu
//
//  Created by Richard Zarth on 5/2/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

class PostTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var posts = [Post]()
    
    var  apiFunctionName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Load JSON data
        loadPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PostTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PostTableViewCell else {
            fatalError("The dequeued cell is not an instance of PostTableViewCell.")
        }

        // Fetches the appropriate post for the data source layout.
        let post = posts[indexPath.row]
        
        cell.likeButton.tag = post.postID
        
        cell.bodyTextLabel.text = post.bodyText
        cell.photoImageView.image = post.image
        cell.tagsLabel.text = post.tagsToString()
        
        if post.isLiked {
            cell.likeButton.setTitle("Unlike", for: .normal)
        } else {
            cell.likeButton.setTitle("Like", for: .normal)
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowDetail":
            guard let navigationViewController = segue.destination as? UINavigationController
                else {
                    fatalError("Unexpected segue destination: \(segue.destination)")
            }
            
            guard let postDetailViewController = navigationViewController.topViewController as? PostDetailViewController
                else {
                    fatalError("Unexpected top view controller: \(String(describing: navigationViewController.topViewController))")
            }
            
            guard let selectedPostCell = sender as? PostTableViewCell
                else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedPostCell)
                else {
                    fatalError("The selected cell is not being displayed by the table.")
            }
            
            let selectedPost = posts[indexPath.row]
            postDetailViewController.post = selectedPost
        case "ShowNewPost":
            print("Show new post")
        default:
            fatalError("Unexpected segue identifier: \(String(describing: segue.identifier))")
        }
        
    }

    //MARK: Private Methods
    
    private func loadPosts() {
        let jsonPayload = [
            "function": apiFunctionName,
            "userID": getUserID(),
            "numberOfPosts": "100",
            "token": getToken()
        ]
        
        callAPI(withJSON: jsonPayload) { (jsonResponse) in
            if let success = jsonResponse["success"] as? Int {
                if (success == 1) {
                    // ***
                    for post in jsonResponse["results"] as! [Dictionary<String, Any>] {
                        let username = post["username"] as! String
                        let bodyText = post["bodyText"] as! String
                        let postID = post["postID"] as! Int
                        let userID = post["userID"] as! Int
                        let imageURL = URL(string: post["imageURL"] as! String)
                        let tags = post["tags"] as! Array<String>
                        let isLiked = post["isLiked"] as! Bool
                        
                        // This is just a temporary image while the real one is loading asynchronously
                        let image = UIImage(named: "placeholder_image")
                        
                        guard let _post = Post(username: username, bodyText: bodyText, postID: postID, userID: userID, image: image, tags: tags, isLiked: isLiked) else {
                            fatalError("Unable to instantiate post")
                        }
                        
                        DispatchQueue.global().async {
                            let data = try? Data(contentsOf: imageURL!)
                            
                            DispatchQueue.main.async {
                                _post.image = UIImage(data: data!)
                                self.tableView.reloadData()
                            }
                        }

                        self.posts += [_post]
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    // ***
                } else {
                    fatalError("getPostsPersonal failed")
                }
            }
        }
    }
}
