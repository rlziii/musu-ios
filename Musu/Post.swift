import UIKit

class Post {
    
    var username: String
    var bodyText: String
    var postID: Int
    var userID: Int
    var image: UIImage?
    var tags: Array<String>
    var isLiked: Bool

    init?(username: String, bodyText: String, postID: Int, userID: Int, image: UIImage?, tags: Array<String>, isLiked: Bool) {
        self.username = username
        self.bodyText = bodyText
        self.postID = postID
        self.userID = userID
        self.image = image
        self.tags = tags
        self.isLiked = isLiked
    }
    
    func tagsToString() -> String {
//        return tags.description
        
        // perhaps a better implementation
         return tags.joined(separator: ", ")
    }
    
}
