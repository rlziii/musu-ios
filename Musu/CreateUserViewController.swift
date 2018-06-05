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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func changeCreateUserStatus(to newStatus: String) {
        createUserStatusLabel.text = newStatus
    }

    private func dismissAllKeyboards() {
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.passwordVerifyTextField.resignFirstResponder()
        self.emailAddressTextField.resignFirstResponder()
    }
    
    private func createUser() {
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
        ]
        
        callAPI(withJSONObject: jsonPayload) { successful, jsonResponse in
            if successful {
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
    
    //MARK: Actions

    @IBAction func createUserButtonTapped(_ sender: UIButton) {
        dismissAllKeyboards()
        
        createUser()
    }
    
}
