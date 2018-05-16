//
//  NewPostViewController.swift
//  Musu
//
//  Created by Richard Zarth on 5/9/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit
import Cloudinary

class NewPostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This will store the URL for an image after being uploaded to Cloudinary
    var imageURL = ""
    
    // MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textBodyTextView: UITextView!
    @IBOutlet weak var tagsTextView: UITextView!
    @IBOutlet weak var submitPostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text fields' user input through delegate callbacks.
        textBodyTextView.delegate = self
        tagsTextView.delegate = self
        
        // Add observers in order to move the view when keyboards activate
        // https://stackoverflow.com/a/31124676
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // TODO: This seems very buggy; research a better method...
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    // TODO: This seems very buggy; research a better method...
    // https://stackoverflow.com/a/45382225
    @objc func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0 {
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
        
        self.view.frame.origin.y = 0
    }
    
    // This will close all keyboards when touching outside of the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textBodyTextView.resignFirstResponder()
        tagsTextView.resignFirstResponder()

        // The method below will potentially close all keyboards possible
        // self.view.endEditing(true)
    }
    
    // Close the keyboard when the "Done" button is pressed.
    // https://stackoverflow.com/a/31601777
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        return true
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
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image
        // We want to use the original
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image
        photoImageView.image = selectedImage
        
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func selectImageFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken
            imagePickerController.sourceType = .photoLibrary
            
            // Make sure NewPostViewController is notified when the user picks an image
            imagePickerController.delegate = self
            
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func selectImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            
            // Only allow photos to be picked, not taken
            imagePickerController.sourceType = .camera
            
            // Make sure NewPostViewController is notified when the user picks an image
            imagePickerController.delegate = self
            
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: Actions
    
    @IBAction func suggestTags(_ sender: UIButton) {
        let group = DispatchGroup()
        
        if imageURL == "" {
            uploadImage(group)
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("After nofity...")
            
            if self.imageURL == "" {
                fatalError("Could not get imageURL after uploadImage()")
            }
            
            guard let bodyText = self.textBodyTextView.text
                else {
                    fatalError("Could not get value for bodyText.")
            }
            
            let jsonPayload = [
                "function": "suggestTags",
                "imageURL": self.imageURL,
                "bodyText": bodyText,
            ]
            
            // NOTES TO SELF
            // This shit don't work
            // Find out how to get tags back from the server
            
            callAPI(withJSON: jsonPayload) { (jsonResponse) in
                if let success = jsonResponse["success"] as? Int {
                    if (success == 1) {
                        if let tags = jsonResponse["results"] as? Array<String> {
                            DispatchQueue.main.async {
                                self.tagsTextView.text = tags.joined(separator: ", ")
                            }
                        }
                    } else {
                        print("Suggest tags failed.")
                    }
                }
            }
        }
    }
    
    // http://swiftdeveloperblog.com/code-examples/actionsheet-example-in-swift/
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        textBodyTextView.resignFirstResponder()
        tagsTextView.resignFirstResponder()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryButton = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) -> Void in
            self.selectImageFromPhotoLibrary()
        })
        
        let cameraButton = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.selectImageFromCamera()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(photoLibraryButton)
        alertController.addAction(cameraButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func uploadImage(_ group: DispatchGroup) {
        group.enter()
        
        let config = CLDConfiguration(cloudName: "cop4331g2", secure: true)
        let cloudinary = CLDCloudinary(configuration: config)
        
        guard let image = photoImageView.image
            else {
                fatalError("Could not unwrap photoImageView.image optional")
        }
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8)
            else {
                fatalError("Could not get data from image")
        }
        
        print("About to upload image...")
        
        DispatchQueue.global(qos: .default).async {
            cloudinary.createUploader().upload(data: imageData, uploadPreset: "musu_preset") { result, error in
                if let error = error {
                    print("Error creating post: \(error.localizedDescription)")
                }
                
                if let result = result {
                    if let url = result.url {
                        print(url)
                        self.imageURL = url
                    }
                }
                
                group.leave()
            }
        }
    }
    
    @IBAction func submitPost(_ sender: UIButton) {
        let group = DispatchGroup()
        
        if imageURL == "" {
            uploadImage(group)
        }
        
        group.notify(queue: DispatchQueue.main) {
        
            if self.imageURL == "" {
                fatalError("Could not get imageURL after uploadImage()")
            }
            
            guard let bodyText = self.textBodyTextView.text
                else {
                    fatalError("Could not get value for bodyText.")
            }
        
            // Create an array out of the tags string...
            let tags = self.tagsTextView.text.split(separator: ",")
        
            let jsonPayload = [
                "function": "createPost",
                "userID": getUserID(),
                "token": getToken(),
                "imageURL": self.imageURL,
                "bodyText": bodyText,
                "tags": tags
                ] as [String : Any]
        
            callAPI(withJSON: jsonPayload) { (jsonResponse) in
                if let success = jsonResponse["success"] as? Int {
                    if (success == 1) {
                        print("New post was created.")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("New post was NOT created.")
                    }
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
}
