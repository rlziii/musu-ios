//
//  NewPostViewController.swift
//  Musu
//
//  Created by Richard Zarth on 5/9/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit
import Cloudinary

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textBodyTextView: UITextView!
    @IBOutlet weak var tagsTextView: UITextView!
    @IBOutlet weak var submitPostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    // MARK: Actions
    
    // TODO: Allow images from camera
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        textBodyTextView.resignFirstResponder()
        tagsTextView.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure NewPostViewController is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func submitPost(_ sender: UIButton) {
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
        cloudinary.createUploader().upload(data: imageData, uploadPreset: "musu_preset") {result, error in
            if let error = error {
                print("Error creating post: \(error.localizedDescription)")
            }
            
            if let result = result {
                if let imageURL = result.url {
                    print(imageURL)
                    
                    // Get the userID
                    guard let userID = UserDefaults.standard.value(forKey: "userID") as? Int
                        else {
                            fatalError("No userID found in UserDefaults!")
                    }
                    
                    // Get the token
                    let token: String
                    do {
                        let tokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                             account: String(userID),
                                                             accessGroup: KeychainConfiguration.accessGroup)
                        
                        token = try tokenItem.readPassword()
                    } catch {
                        fatalError("Error reading token from Keychain - \(error)")
                    }
                    
                    let bodyText = self.textBodyTextView.text
                    let tags = self.tagsTextView.text
                    
                    let jsonPayload = [
                        "function": "createPost",
                        "userID": String(userID),
                        "token": token,
                        "imageURL": imageURL,
                        "bodyText": bodyText,
                        "tags": tags
                    ] as! Dictionary<String, String>
                    
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
        }
    }
    
}
