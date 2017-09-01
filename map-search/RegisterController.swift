//
//  RegisterController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 15/03/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit

class RegisterController: UIViewController, UITextFieldDelegate {

    
    // MARK: Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        nameTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
    }

    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        if textField === confirmTextField {
            //Check if passwords match
            if passwordTextField.text != confirmTextField.text {
                displayAlertMessage("Password no match")
                return
            }
        }
    }
    
    /*@IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }*/
    
    // MARK: Actions
    
    @IBAction func tapBackground(_ sender: UIControl) {
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmTextField.resignFirstResponder()
    }
    
    
    @IBAction func registerButton(_ sender: UIButton) {
        
        //Get strings from TextFields
        let name = nameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirm = confirmTextField.text!
        
        //Check for empty fields
        if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
            displayAlertMessage("Missing empty fields")
            return
        }
        
        requestToServer(name, email: email, password: password)
    }
    
    // MARK: Private Methods
    
    private func requestToServer(_ name:String, email:String, password:String) {
        
        //Request to server
        let url = NSURL(string: "http://148.204.66.28/server/userRegister.php")
        let request = NSMutableURLRequest(url: url! as URL)
        
        //Http Body
        request.httpMethod = "POST"
        let postString = "name=\(name)&email=\(email)&password=\(password)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Task
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if let messageError = error {
                print("Error register:\(messageError)")
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                if let parseJSON = json {
                    let resultValue = parseJSON["status"] as! String!
                    
                    print("result: \(resultValue ?? "No hay")")
                    
                    /*var userSignedIn = false
                    
                    if(resultValue == "Success") {
                        userSignedIn = true
                    }
                    */
                    let messageToDisplay = parseJSON["message"] as! String!
                    
                    DispatchQueue.main.async{
                        self.displayAlertMessage(messageToDisplay!)
                    }
                    
                }
            }
            catch _{print("Error: \(error ?? "Break" as! Error)")}
            
        }
        
        task.resume()
    }
    
    // MARK: Alert
    
    private func displayAlertMessage(_ message: String) {
        
        //Create Alert Controller
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
