//
//  PostTableViewController.swift
//  Musu
//
//  Created by Richard Zarth on 5/2/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

// This is an array of DispatchWorkItems that handle the downloading of images...
var imageDownloadTasks = [DispatchWorkItem]()

// This is global to allow the use of cache throughout all PostTableViewControllers
// Is there perhaps a better way to accomplish this?
let imageCache = NSCache<NSString, UIImage>()

class PostTableViewController: UITableViewController, PostCellDelegate {
    
    func didPressDeleteButton(_ postID: Int) {
        let jsonPayload = [
            "function": "deletePost",
            "userID": getUserID(),
            "token": getToken(),
            "postID": String(postID)
        ]
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
                self.loadPosts()
            } else {
                print("Failed to delete post: \(String(describing: jsonResponse["error"]))")
            }
        }
    }
    
    func didPressLikeButton(_ postID: Int, _ currentButtonTitle: String, _ sender: PostTableViewCell) {
        var apiFunctionName: String
        var newButtonTitle: String
        
        if currentButtonTitle == "Like" {
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
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
                DispatchQueue.main.async {
                    sender.likeButton.setTitle(newButtonTitle, for: .normal)
                }
            } else {
                print("Failed to like/unlike post: \(String(describing: jsonResponse["error"]))")
                return
            }
        }
    }
    
    // TODO: Possible crash when the app is recovering from a save state
    
    // https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
    private var refreshController: UIRefreshControl? = nil
    
    //MARK: Properties
    
    var posts = [Post]()
    
    var  apiFunctionName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refreshController = UIRefreshControl()
        
        tableView.refreshControl = refreshController
        
        refreshController?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshController?.attributedTitle = NSAttributedString(string: "Refreshing posts...")
        
        // Load JSON data
        loadPosts()
    }
    
    @objc private func refreshData(_ sender: Any) {
//        tableView.isUserInteractionEnabled = false
        loadPosts()
//        tableView.isUserInteractionEnabled = true
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

        cell.postCellDelegate = self
        
        // Fetches the appropriate post for the data source layout.
        let post = posts[indexPath.row]
        
        cell.likeButton.tag = post.postID
        cell.deleteButton.tag = post.postID
        
        cell.bodyTextLabel.text = post.bodyText
        cell.photoImageView.image = post.image
        cell.tagsLabel.text = post.tagsToString()
        
        if post.isLiked {
            cell.likeButton.setTitle("Unlike", for: .normal)
        } else {
            cell.likeButton.setTitle("Like", for: .normal)
        }
        
        cell.deleteButton.isHidden = post.userID == Int(getUserID()) ? false : true
        
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

    // https://medium.com/journey-of-one-thousand-apps/caching-images-in-swift-e909a8e5db17
    private func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let imageDownloadTask = DispatchWorkItem {
            if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                print("Image retrieved from cache")
                completion(cachedImage)
            } else {
                print("Downloading image from server")
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    print("Image saved to cache")
                    
                    completion(image)
                } else {
                    fatalError("Could not set image cache")
                }
            }
        }
        
        imageDownloadTasks.append(imageDownloadTask)
        
        imageDownloadTask.perform()
    }
    
    public func loadPosts() {
        // TODO: The refresh for this needs to be much more effecient (especially for getPostsLatest)
        // Perhaps check to see if it's already in the list and don't update the image...
        
        let jsonPayload = [
            "function": apiFunctionName,
            "userID": getUserID(),
            "numberOfPosts": "100",
            "token": getToken()
        ]
        
        var newPosts = [Post]()
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
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
                    
                    DispatchQueue.global(qos: .background).async {
                        guard let imageURL = imageURL
                            else {
                                fatalError("Unable to fetch image URL")
                        }
                        
                        self.downloadImage(url: imageURL, completion: { image in
                            DispatchQueue.main.async {
                                _post.image = image
                                self.tableView.reloadData()
                            }
                        })
                    }

                    newPosts.append(_post)
                    self.posts.append(_post)
                }
            } else {
                fatalError("getPostsPersonal failed")
            }
            
            DispatchQueue.main.async {
                self.refreshController?.endRefreshing()
                
                self.posts.removeAll(keepingCapacity: false)
                self.posts = newPosts
                newPosts.removeAll(keepingCapacity: false)
                
                self.tableView.reloadData()
            }
        }
    }
}
