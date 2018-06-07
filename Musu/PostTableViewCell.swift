import UIKit

protocol PostCellDelegate: class {
    func didTapDeleteButton(_ postID: Int)
    func didTapLikeButton(_ postID: Int, _ isLiked: Bool, _ sender: PostTableViewCell, Completion block: @escaping (Bool) -> ())
}

class PostTableViewCell: UITableViewCell {
    
    weak var postCellDelegate: PostCellDelegate?
    
    var isLiked = false
    var postID = 0
    
    // MARK: Properties
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func populateCellData(withPost post: Post) {
        bodyTextLabel.text = post.bodyText
        photoImageView.image = post.image
        tagsLabel.text = post.tagsToString()
        
        postID = post.postID
        isLiked = post.isLiked
        updateLikeButtonTitle()
        
        deleteButton.isHidden = post.userID == Int(getUserID()) ? false : true
    }
    
    func updateLikeButtonTitle() {
        if isLiked {
            likeButton.setTitle("Unlike", for: .normal)
        } else {
            likeButton.setTitle("Like", for: .normal)
        }
    }
    
    // MARK: Actions
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        postCellDelegate?.didTapDeleteButton(postID)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        postCellDelegate?.didTapLikeButton(postID, isLiked, self) { successful in
            if successful {
                DispatchQueue.main.async {
                    self.isLiked = !self.isLiked
                    self.updateLikeButtonTitle()
                }
            }
        }
    }
    
}
