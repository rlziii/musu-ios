//
//  SecondViewController.swift
//  Musu
//
//  Created by Richard Zarth on 4/19/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {
    
    //MARK: Properties

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordVerifyTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var createUserStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeCreateUserStatus(to: String) {
        createUserStatusLabel.text = to
    }

    //MARK: Actions

    @IBAction func createUser(_ sender: UIButton) {
        // Dismiss the keyboard when login button is pressed
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordVerifyTextField.resignFirstResponder()
        self.emailAddressTextField.resignFirstResponder()

        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        let username = usernameTextField.text
        let password = passwordTextField.text
        let passwordVerify = passwordVerifyTextField.text
        let emailAddress = emailAddressTextField.text
        
        // Verify that the passwords match
        if password != passwordVerify {
            changeCreateUserStatus(to: "Passwords do not match.")
            
            return
        }
        
        // Ensure that all fields are filled out
        if firstName == "" || lastName == "" || username == "" || password == "" || emailAddress == "" {
            changeCreateUserStatus(to: "Not all fields are filled out.")
            
            return
        }
        
        let jsonPayload = [
            "function": "createUser",
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
                        self.changeCreateUserStatus(to: (jsonResponse["message"])! as! String)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.changeCreateUserStatus(to: (jsonResponse["error"])! as! String)
                    }
                }
            }
        }
    }
}
