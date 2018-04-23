//
//  FirstViewController.swift
//  Musu
//
//  Created by Richard Zarth on 4/19/18.
//  Copyright © 2018 RLZIII. All rights reserved.
//

/*
 * TODO LIST
 *
 * Set NSAllowsArbitraryLoads to NO (Info.plist)
 *
 */

import UIKit

class FirstViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeLoginStatus(to: String) {
        loginStatusLabel.text = to
    }
    
    //MARK: Actions

    @IBAction func loginButton(_ sender: UIButton) {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        let json = ["function": "loginWithUsername", "username": username, "password": password] as! Dictionary<String, String>
        
        connectToAPI(withJSON: json) { (json) in
            if let success = json["success"] as? Int {
                if (success == 1) {
                    DispatchQueue.main.async {
                        self.changeLoginStatus(to: (json["message"])! as! String)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.changeLoginStatus(to: (json["error"])! as! String)
                    }
                }
            }
        }
    }
}
// https://developer.apple.com/documentation/code_diagnostics/main_thread_checker

