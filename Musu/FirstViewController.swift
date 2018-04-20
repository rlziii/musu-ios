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
        
        let parameters = ["function": "loginAttempt", "username": username, "password": password] as! Dictionary<String, String>
        
        let url = URL(string: "http://www.musuapp.com/API/API.php")!
        
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    
                    print(json)
                    
                    // https://developer.apple.com/documentation/code_diagnostics/main_thread_checker
                    
                    if let success = json["success"] as? Int {
                        if (success == 1) {
                            DispatchQueue.main.async {
                                self.changeLoginStatus(to: json["message"] as! String)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.changeLoginStatus(to: json["error"] as! String)
                            }
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }

}
