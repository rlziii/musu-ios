import UIKit

// This is an array of DispatchWorkItems that handle the downloading of images...
var imageDownloadTasks = [DispatchWorkItem]()

// This is global to allow the use of cache throughout all PostTableViewControllers
// TODO: Is there perhaps a better way to accomplish this?
let imageCache = NSCache<NSString, UIImage>()

class PostTableViewController: UITableViewController, PostCellDelegate {
    
    // https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
    private var refreshController: UIRefreshControl? = nil
    
    var posts = [Post]()
    var apiFunctionName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshController = UIRefreshControl()
        
        tableView.refreshControl = refreshController
        
        refreshController?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshController?.attributedTitle = NSAttributedString(string: "Refreshing posts...")
        
        loadPosts()
    }
    
    @objc private func refreshData(_ sender: Any) {
        loadPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "PostTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PostTableViewCell else {
            fatalError("The dequeued cell is not an instance of PostTableViewCell.")
        }
        
        // Fetches the appropriate post for the data source layout
        let post = posts[indexPath.row]
        
        cell.populateCellData(withPost: post)
        
        cell.postCellDelegate = self
        
        return cell
    }

    func didTapDeleteButton(_ postID: Int) {
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
    
    func didTapLikeButton(_ postID: Int, _ isLiked: Bool, _ sender: PostTableViewCell, Completion block: @escaping (Bool) -> ()) {
        let functionName = isLiked ? "unlikePost" : "likePost"
        
        let jsonPayload = [
            "function": functionName,
            "userID": getUserID(),
            "token": getToken(),
            "postID": String(postID)
        ]
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
                block(true)
            } else {
                print("Failed to like/unlike post: \(String(describing: jsonResponse["error"]))")
                block(false)
            }
        }
    }
    
    // MARK: Navigation

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
