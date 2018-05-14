//
//  SecondViewController.swift
//  Musu
//
//  Created by Richard Zarth on 4/19/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var newFirstNameTextField: UITextField!
    @IBOutlet weak var newLastNameTextField: UITextField!
    @IBOutlet weak var newUsernameTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordVerifyTextField: UITextField!
    @IBOutlet weak var newEmailAddressTextField: UITextField!
    
    @IBOutlet weak var updateUserStatusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeUpdateUserStatus(to: String) {
        updateUserStatusLabel.text = to
    }

    //MARK: Actions

    @IBAction func updateUser(_ sender: UIButton) {
        
        // Dismiss the keyboard when login button is pressed
        self.newFirstNameTextField.resignFirstResponder()
        self.newLastNameTextField.resignFirstResponder()
        self.newUsernameTextField.resignFirstResponder()
        self.newPasswordTextField.resignFirstResponder()
        self.newPasswordVerifyTextField.resignFirstResponder()
        self.newEmailAddressTextField.resignFirstResponder()
        
        let firstName = newFirstNameTextField.text
        let lastName = newLastNameTextField.text
        let username = newUsernameTextField.text
        let password = newPasswordTextField.text
        let passwordVerify = newPasswordVerifyTextField.text
        let emailAddress = newEmailAddressTextField.text
        
        // Verify that the passwords match
        if password != "" && password != passwordVerify {
            changeUpdateUserStatus(to: "Passwords do not match.")
            
            return
        }
        
        // Ensure that all fields are filled out
        if firstName == "" && lastName == "" && username == "" && password == "" && emailAddress == "" {
            changeUpdateUserStatus(to: "At least one field must be filled out.")
            
            return
        }
        
        let jsonPayload = [
            "function": "updateUser",
            "userID": getUserID(),
            "token": getToken(),
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "password": password,
            "emailAddress": emailAddress,
            ] as! Dictionary<String, String>
        
        callAPI(withJSON: jsonPayload) { (jsonResponse) in
            if let success = jsonResponse["success"] as? Int {
                if (success == 1) {
                    DispatchQueue.main.async {
                        self.changeUpdateUserStatus(to: (jsonResponse["message"])! as! String)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.changeUpdateUserStatus(to: (jsonResponse["error"])! as! String)
                    }
                }
            }
        }
    }
}
